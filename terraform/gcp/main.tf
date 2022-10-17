terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("tfm-uc3m-365809-dbee44e928c4.json")

  project = "tfm-uc3m-365809"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}
