resource "google_service_account" "gke_deployment_service_account" {
  project      = var.project_id
  account_id   = "gke-deployment"
  display_name = "Service Account for deployment to write to GCR and GKE"
}

resource "google_project_iam_member" "gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.gke_deployment_service_account.email}"
}

resource "google_project_iam_member" "artifactregistry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.gke_deployment_service_account.email}"
}