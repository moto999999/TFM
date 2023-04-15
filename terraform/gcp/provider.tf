provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = true
  location      = "EU"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}