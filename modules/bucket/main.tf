resource "google_storage_bucket" "bucket" {
  location                 = var.location
  project                  = var.project
  name                     = "${var.name_prefix}-${uuid()}"
  force_destroy            = var.force_destroy
  public_access_prevention = "enforced"

  versioning {
    enabled = false
  }
}
