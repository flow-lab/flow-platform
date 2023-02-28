variable "name_prefix" {
  description = "The name prefix to use for the bucket."
  type        = string
}

variable "location" {
  description = "The location of the bucket."
  default     = "EU"
  type        = string
}

variable "project" {
  description = "The project ID to deploy to."
  type        = string
}