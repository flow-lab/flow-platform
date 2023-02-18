# ----------------------------------------------------------------------------------------------------------------------
#  Networking
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnetwork" {
  name                     = "${var.prefix}-control-plane"
  region                   = var.region
  network                  = var.network_self_link
  ip_cidr_range            = var.control_plane_subnetwork_cidr_block
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "${var.prefix}-control-plane-router"
  region  = google_compute_subnetwork.subnetwork.region
  network = var.network_self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                   = "${var.prefix}-control-plane-nat"
  nat_ip_allocate_option = "AUTO_ONLY"
  router                 = google_compute_router.router.name
  region                 = google_compute_router.router.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnetwork.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_managed_ssl_certificate" "api_cert" {
  count    = var.domain == "" ? 0 : 1
  provider = google-beta

  name = element(split(".", var.domain), 0)

  managed {
    domains = [
      "api.${var.domain}"
    ]
  }
}

# Configure A record pointing to this IP address
resource "google_compute_global_address" "ip" {
  name = "${var.prefix}-load-balancer"
}

resource "google_dns_managed_zone" "prod" {
  count    = var.domain == "" ? 0 : 1
  name     = "${var.prefix}-zone"
  dns_name = "${var.domain}."
}

// domain name to associate to ingress lb
resource "google_dns_record_set" "dns" {
  count        = var.domain == "" ? 0 : 1
  name         = "api.${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.prod[0].name

  rrdatas = [
    google_compute_global_address.ip.address
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
#  Cluster
# ----------------------------------------------------------------------------------------------------------------------

resource "google_container_cluster" "primary" {
  name               = "${var.prefix}-cluster"
  location           = var.location
  provider           = google
  min_master_version = "1.25.6-gke.200"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = false
  initial_node_count       = 1

  network    = var.network_self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  # enable client certificate authentication
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  ip_allocation_policy {
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "00:00"
    }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.k8s_master_cidr_block
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }

  enable_shielded_nodes = true

  vertical_pod_autoscaling {
    enabled = true
  }
}

resource "google_container_node_pool" "primary_node_pool" {
  name               = "standard"
  location           = var.location
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1
  provider           = google-beta

  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = "n2-standard-2"

    labels = {
      nodetype = "standard"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_container_node_pool" "highmem_node_pool" {
  count              = var.highmem_node_pool ? 1 : 0
  name_prefix        = "highmem-"
  location           = var.location
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1
  provider           = google-beta

  autoscaling {
    max_node_count = 3
    min_node_count = 0
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = "n2-highmem-4"

    labels = {
      nodetype = "highmem"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    tags = ["mem"]
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_container_node_pool" "gpu_node_pool" {
  count              = var.gpu_node_pool ? 1 : 0
  name_prefix        = "gpu-"
  location           = var.location
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1
  provider           = google-beta

  autoscaling {
    max_node_count = 1
    min_node_count = 0
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    labels = {
      nodetype    = "gpu"
      accelerator = "nvidia-tesla-v100"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    guest_accelerator {
      count = 1
      type  = "nvidia-tesla-v100"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    tags = ["gpu"]
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
  }

  lifecycle {
    create_before_destroy = true
  }

}

# ----------------------------------------------------------------------------------------------------------------------
#  Service Account
# ----------------------------------------------------------------------------------------------------------------------
resource "google_service_account" "sa" {
  account_id   = "${var.prefix}-sa"
  display_name = var.prefix
}

resource "google_service_account_key" "account_key" {
  service_account_id = google_service_account.sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 5"
  }
  triggers = {
    "after" = google_service_account.sa.id
  }
}