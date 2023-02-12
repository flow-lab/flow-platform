variable "name" {
  description = "The db name."
  type        = string
}

variable "db_tier" {
  description = "The db tier."
  type        = string
  default     = "db-f1-micro"
}

variable "database_version" {
  description = "The database version."
  type        = string
  default     = "POSTGRES_14"
}

variable "region" {
  description = "The region."
}

variable "tf_deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply command that deletes the instance will fail. Defaults to true."
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Enables deletion protection of an instance at the GCP level. Enabling this protection will guard against accidental deletion across all surfaces (API, gcloud, Cloud Console and Terraform) by enabling the GCP Cloud SQL instance deletion protection."
  type        = bool
  default     = false
}