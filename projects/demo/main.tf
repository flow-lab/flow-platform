data "google_client_config" "current" {}
data "google_project" "project" {}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = file(var.credentials)
  project     = data.google_project.project.project_id
  region      = var.region
}

provider "kubernetes" {
  host                   = module.gke.cluster_endpoint != "" ? "https://${module.gke.cluster_endpoint}" : ""
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

terraform {
  backend "gcs" {
    bucket = "flow-platform-terraform-state"
    prefix = "/terraform/state/flow-platform-infra"
  }
}

module "network" {
  source   = "../../modules/network"
  prefix   = var.prefix
  region   = var.region
  location = "europe-west4-a"
}

module "gke" {
  source            = "../../modules/gke"
  prefix            = var.prefix
  domain            = var.domain
  region            = var.region
  location          = "europe-west4"
  network_self_link = module.network.network_self_link
}

module "ingress" {
  source    = "../../modules/ingress"
  prefix    = var.prefix
  ip_name   = module.gke.gke_ingress_name
  cert_name = module.gke.ssl_cert_name
  domain    = var.domain
}

#module "cache" {
#  source             = "../../modules/redis"
#  prefix             = var.prefix
#  authorized_network = module.network.network_self_link
#  region             = var.region
#}

module "db" {
  source                  = "../../modules/db"
  name                    = "db"
  region                  = var.region
  tf_deletion_protection  = false
  private_ip_address      = module.network.private_ip_address.address
  private_ip_address_name = module.network.private_ip_address.name
  private_network_id      = module.network.network_id
}

module "gar" {
  source = "../../modules/gar"
  region = var.region
  repositories = [
    {
      name        = "apps"
      description = "The docker apps repository"
    }
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
#  CI/CD module
#  NOTE: for security reasons, this needs a special permissions set on the service account for terraform
#        to run (editor -> owner -> editor)
# ----------------------------------------------------------------------------------------------------------------------
module "cicd" {
  source     = "../../modules/cicd"
  project_id = var.project_id
}

# ----------------------------------------------------------------------------------------------------------------------
#  Redis Kubernetes Config
# ----------------------------------------------------------------------------------------------------------------------
#resource "kubernetes_config_map" "redis_config" {
#  metadata {
#    name = "${module.cache.name}-config"
#  }
#
#  data = {
#    name = "projects/${data.google_project.project.project_id}/locations/${var.region}/instances/${module.cache.name}"
#  }
#}

# ----------------------------------------------------------------------------------------------------------------------
#  DB Kubernetes Config
# ----------------------------------------------------------------------------------------------------------------------
resource "kubernetes_config_map" "db_config" {
  metadata {
    name = "db-config"
  }

  data = {
    DB_HOST                  = module.db.private_ip
    DB_USER                  = module.db.db_user
    DB_PORT                  = 5432
    INSTANCE_CONNECTION_NAME = module.db.instance_connection_name
  }
}

resource "kubernetes_secret" "db_pass_secret" {
  metadata {
    name = "db-pass-secret"
  }

  data = {
    DB_PASS = module.db.db_password
  }
}

resource "kubernetes_secret" "db_tls_secret" {
  metadata {
    name = "db-tls-secret"
  }

  data = {
    "server-ca.pem"   = module.db.client_cert.server_ca_cert
    "client-cert.pem" = module.db.client_cert.cert
    "client-key.pem"  = module.db.client_cert.private_key
  }
}

# ----------------------------------------------------------------------------------------------------------------------
#  Add database for diatom-pub app
# ----------------------------------------------------------------------------------------------------------------------
resource "google_sql_database" "diatom" {
  instance        = module.db.name
  name            = "diatom"
  deletion_policy = "ABANDON"
}

# ----------------------------------------------------------------------------------------------------------------------
#  diatom-pub Kubernetes Config
#  https://github.com/flow-lab/diatom-pub
# ----------------------------------------------------------------------------------------------------------------------
resource "kubernetes_config_map" "diatom_pub_config" {
  metadata {
    name = "diatom-pub-config"
  }

  data = {
    PORT         = 8080
    DB_NAME      = google_sql_database.diatom.name
    DB_CERT_PATH = "/etc/client-cert"
    REDIS_HOST   = "localhost"
    REDIS_PORT   = 6379
    LOG_LEVEL    = "debug"
  }
}

# init db container using flowdber
resource "kubernetes_config_map" "diatom_pub_flowdber_config" {
  metadata {
    name = "diatom-pub-flowdber-config"
  }

  data = {
    DB_NAME      = google_sql_database.diatom.name
    DB_CERT_PATH = "/etc/client-cert"
  }
}

module "diatom-pub-sql" {
  source = "git::https://github.com/flow-lab/diatom-pub.git//srv/module/infra?ref=main"
}

module "bucket" {
  source      = "../../modules/bucket"
  name_prefix = "flow-platform"
  location    = var.region
  project     = var.project_id
}