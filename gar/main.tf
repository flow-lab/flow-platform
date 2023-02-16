locals {
  repos = flatten([
    for repo in var.repositories : [
      {
        name        = repo.name
        description = repo.description
      }
    ]
  ])
}

resource "google_artifact_registry_repository" "repository" {
  count         = length(local.repos)
  provider      = google
  format        = "DOCKER"
  repository_id = local.repos[count.index].name
  location      = var.region
  description   = local.repos[count.index].description != null ? local.repos[count.index].description : "${local.repos[count.index].name} repository"
}