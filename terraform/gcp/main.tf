terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.42.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)

  project = var.project
  region  = var.region
  zone    = var.zone
}
