variable "prefix" {
  description = "Prefix name."
}

variable "region" {
  type        = string
  description = "GCP default region for all resources."
}

variable "location" {
  type        = string
  description = "GCP default location for all resources."
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
  description = "Base domain"
}

variable "highmem_node_pool" {
  description = "Enable highmem node pool"
  type        = bool
  default     = false
}

variable "gpu_node_pool" {
  description = "Enable gpu node pool"
  type        = bool
  default     = false
}
