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
  name     = local.db_user
  instance = google_sql_database_instance.db.name
  password = google_secret_manager_secret_version.db_password.secret_data
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
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
      ipv4_enabled = true
      require_ssl  = true
    }
  }
}
