data "google_client_config" "current" {
}

variable "prefix" {
  default     = "flow-platform"
  description = "Project prefix name."
}

variable "project_id" {
  type        = string
  default     = "flow-platform"
  description = "Project id."
}

variable "credentials" {
  type        = string
  description = "Google application credentials file path."
}

variable "region" {
  type        = string
  default     = "europe-west4"
  description = "GCP default region for all resources."
}

variable "control_plane_subnetwork_cidr_block" {
  default     = "10.0.16.0/24"
  description = "Subnetwork's primary ip range."
}

variable "k8s_master_cidr_block" {
  default     = "10.0.64.0/28"
  description = "K8s master ipv4 cidr block"
}

variable "domain" {
  description = "Base domain. Used for DNS records to point to the ingress. When empty no DNS records will be created."
  type        = string
  default     = ""
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

provider "kubernetes" {
  host                   = module.gke.cluster_endpoint
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

# ----------------------------------------------------------------------------------------------------------------------
#  Redis Kubernetes Config
# ----------------------------------------------------------------------------------------------------------------------
resource "kubernetes_config_map" "redis_config" {
  metadata {
    name = "${module.cache.name}-config"
  }

  data = {
    name = "projects/${var.project_id}/locations/${var.region}/instances/${module.cache.name}"
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
    name = "projects/${var.project_id}/locations/${var.region}/instances/${module.db.name}"
  }
}