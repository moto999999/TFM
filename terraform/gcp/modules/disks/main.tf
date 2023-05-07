resource "google_compute_disk_resource_policy_attachment" "attachment" {
  name = google_compute_resource_policy.policy.name
  disk = google_compute_disk.nfs_disk.name
  zone = var.zone
}

resource "google_compute_disk" "nfs_disk" {
  name = "pv-disk"
  zone = var.zone

  type = var.disk_type["ssd"]
  size = var.disk_size_gb

}

resource "google_compute_snapshot" "snap_nfs_disk" {
  name  = "nfs-snapshot-3-days"
  source_disk = google_compute_disk.nfs_disk.name
  zone        = var.zone
}

resource "google_compute_resource_policy" "policy" {
  name = "nfs-disk-policy"
  region = var.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "04:00"
      }
    }
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
  }
}
