variable "name_prefix" {
  description = "The name prefix to use for the bucket."
  type        = string
  default     = "bucket"
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

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "versioning" {
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
  type        = bool
  default     = false
}