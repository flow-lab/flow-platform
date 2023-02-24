# ----------------------------------------------------------------------------------------------------------------------
#  DB
# ----------------------------------------------------------------------------------------------------------------------
locals {
  db_name = "${var.name}-${random_id.db_name_suffix.hex}"
  db_user = "root"
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "${local.db_name}-${local.db_user}-password"
  replication {
    automatic = true
  }
}

resource "google_sql_user" "users" {
  name            = local.db_user
  instance        = google_sql_database_instance.db.name
  password        = google_secret_manager_secret_version.db_password.secret_data
  deletion_policy = "ABANDON"
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

variable "private_ip_address" {
}
variable "private_ip_address_name" {
}
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.private_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [var.private_ip_address_name]
}

// TODO [grokrz]: clean up
variable "private_network_id" {
  default = ""
}
resource "google_sql_database_instance" "db" {
  name             = local.db_name
  database_version = var.database_version

  region = var.region

  deletion_protection = var.tf_deletion_protection

  settings {
    tier                        = var.db_tier
    deletion_protection_enabled = var.deletion_protection_enabled

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.private_network_id
      enable_private_path_for_google_cloud_services = true
      require_ssl                                   = true
    }
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_ssl_cert" "client_cert" {
  common_name = "client-cert"
  instance    = google_sql_database_instance.db.name
}