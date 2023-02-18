variable "repositories" {
  description = "List of repositories to create in artifactory."
  type = set(object({
    name        = string
    description = optional(string)
  }))
}

variable "region" {
  description = "The region."
}