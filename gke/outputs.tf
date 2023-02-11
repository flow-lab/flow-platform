output "gke_ingress_ip" {
  value = google_compute_global_address.ip.address
}

output "gke_ingress_name" {
  value = google_compute_global_address.ip.name
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "client_certificate" {
  value     = google_container_cluster.primary.master_auth[0].client_certificate
  sensitive = true
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "service_account_key" {
  value     = google_service_account_key.account_key.private_key
  sensitive = true
}

output "ssl_cert_name" {
  value = google_compute_managed_ssl_certificate.api_cert.*.name
}

output "ssl_cert_link" {
  sensitive = false
  value     = google_compute_managed_ssl_certificate.api_cert.*.self_link
}

output "vpc_link" {
  value = google_compute_network.network.self_link
}

output "client_key" {
  value     = google_container_cluster.primary.master_auth[0].client_key
  sensitive = true
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}