output "name" {
  value = google_sql_database_instance.db.name
}

output "db_user" {
  value = local.db_user
}

output "db_password_secret_manager_secret_id" {
  value = google_secret_manager_secret.db_password.secret_id
}

output "db_password" {
  value     = google_secret_manager_secret_version.db_password.secret_data
  sensitive = true
}

output "db_name" {
  value = local.db_name
}

output "public_ip_address" {
  value = google_sql_database_instance.db.public_ip_address
}

output "instance_connection_name" {
  value = google_sql_database_instance.db.connection_name
}

output "client_cert" {
  value = google_sql_ssl_cert.client_cert
}
