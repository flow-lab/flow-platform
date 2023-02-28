resource "google_storage_bucket" "bucket" {
  location                 = var.location
  project                  = var.project
  name                     = "${var.name_prefix}-${uuid()}"
  force_destroy            = true
  public_access_prevention = "enforced"
}

# Google Vertex AI requires the following permissions:
#locals {
#  members =
#    "serviceAccount:12345678-compute@developer.gserviceaccount.com"
#}
#
#resource "google_storage_bucket_iam_binding" "bucket" {
#  bucket = google_storage_bucket.bucket.name
#  role   = "roles/storage.objectCreator"
#  members = [
#    local.members
#  ]
#}
#
#resource "google_storage_bucket_iam_member" "bucket" {
#  bucket = google_storage_bucket.bucket.name
#  role   = "roles/storage.objectViewer"
#  member = local.members
#}
