resource "google_dns_managed_zone" "k8s_tfm" {
  cloud_logging_config {
    enable_logging = "false"
  }

  dnssec_config {
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = "1024"
      key_type   = "zoneSigning"
      kind       = "dns#dnsKeySpec"
    }

    default_key_specs {
      algorithm  = "rsasha256"
      key_length = "2048"
      key_type   = "keySigning"
      kind       = "dns#dnsKeySpec"
    }

    kind          = "dns#managedZoneDnsSecConfig"
    non_existence = "nsec3"
    state         = "off"
  }

  dns_name = "k8s-tfm.tk."

  name          = "k8s-tfm"
  visibility    = "public"
}

resource "google_dns_record_set" "prometheus" {
  managed_zone = google_dns_managed_zone.k8s_tfm.name
  name         = format("%s.%s", "prometheus", google_dns_managed_zone.k8s_tfm.dns_name)
  rrdatas      = [google_compute_global_address.k8s_lb.address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "prometheus_alertmanager" {
  managed_zone = google_dns_managed_zone.k8s_tfm.name
  name         = format("%s.%s", "prometheus-alertmanager", google_dns_managed_zone.k8s_tfm.dns_name)
  rrdatas      = [google_compute_global_address.k8s_lb.address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "grafana" {
  managed_zone = google_dns_managed_zone.k8s_tfm.name
  name         = format("%s.%s", "grafana", google_dns_managed_zone.k8s_tfm.dns_name)
  rrdatas      = [google_compute_global_address.k8s_lb.address]
  ttl          = 300
  type         = "A"
}
