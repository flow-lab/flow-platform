# ----------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ----------------------------------------------------------------------------------------------------------------------
variable "prefix" {
  default     = "flow-platform"
  description = "Project prefix name."
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

variable "project_id" {
  description = "GCP project id."
  type        = string
  default     = "flow-platform"
}

variable "gha_timeout" {
  description = "Github action timeout in seconds."
  type        = number
  default     = 120
}