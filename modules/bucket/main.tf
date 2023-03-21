# generate uuid for bucket name but persist it in state
resource "random_uuid" "bucket_name" {}

resource "google_storage_bucket" "bucket" {
  location                 = var.location
  project                  = var.project
  name                     = "${var.name_prefix}-${random_uuid.bucket_name.result}"
  force_destroy            = var.force_destroy
  public_access_prevention = "enforced"

  versioning {
    enabled = var.versioning
  }
}
