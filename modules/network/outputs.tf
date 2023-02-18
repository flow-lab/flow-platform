output "network_id" {
  value = google_compute_network.network.id
}

output "network_name" {
  value = google_compute_network.network.name
}

output "network_self_link" {
  value = google_compute_network.network.self_link
}

output "private_ip_address" {
  value = google_compute_global_address.private_ip_address
}