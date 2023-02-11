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
  default     = "postgres_14"
}

variable "region" {
  description = "The region."
}