resource "google_service_account" "gke_deployment_service_account" {
  account_id   = "gke-deployment"
  display_name = "Service Account for deployment to write to GCR and GKE"
}

resource "google_project_iam_member" "gke_developer" {
  project = data.google_project.project.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.gke_deployment_service_account.email}"
}

resource "google_project_iam_member" "artifactregistry_writer" {
  project = data.google_project.project.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.gke_deployment_service_account.email}"
}