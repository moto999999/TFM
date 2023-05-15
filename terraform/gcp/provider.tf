provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone

  credentials = file("tfm-uc3m-sa.json")
}
