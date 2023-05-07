provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone

  credentials = file("tfm-uc3m-379318-e6168998842b.json")
}
