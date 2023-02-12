# ----------------------------------------------------------------------------------------------------------------------
#  DB
# ----------------------------------------------------------------------------------------------------------------------
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "db" {
  name             = "${var.name}-${random_id.db_name_suffix.hex}"
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
