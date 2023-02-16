data "google_client_config" "current" {
}

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

module "gke" {
  source   = "./gke"
  domain   = var.domain
  prefix   = var.prefix
  region   = var.region
  location = "europe-west4-a"
}

module "ingress" {
  source    = "./ingress"
  prefix    = var.prefix
  ip_name   = module.gke.gke_ingress_name
  cert_name = module.gke.ssl_cert_name
  domain    = var.domain
}

module "cache" {
  source             = "./redis"
  prefix             = var.prefix
  authorized_network = module.gke.vpc_link
  region             = var.region
}

module "db" {
  source                 = "./db"
  name                   = "db"
  region                 = var.region
  tf_deletion_protection = false
}

module "gar" {
  source = "./gar"
  region = var.region
  repositories = [
    {
      name        = "apps"
      description = "The docker apps repository"
    }
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
#  Redis Kubernetes Config
# ----------------------------------------------------------------------------------------------------------------------
resource "kubernetes_config_map" "redis_config" {
  metadata {
    name = "${module.cache.name}-config"
  }

  data = {
    name = "projects/${data.google_project.project.project_id}/locations/${var.region}/instances/${module.cache.name}"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
#  DB Kubernetes Config
# ----------------------------------------------------------------------------------------------------------------------
resource "kubernetes_config_map" "db_config" {
  metadata {
    name = "${module.db.name}-config"
  }

  data = {
    name = "projects/${data.google_project.project.project_id}/locations/${var.region}/instances/${module.db.name}"
  }
}
