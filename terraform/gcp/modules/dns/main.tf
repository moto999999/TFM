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

  dns_name = var.dns_name

  name          = "dns-k8s"
  visibility    = "public"
}

resource "google_dns_record_set" "dns_records" {
  for_each = toset(var.dns_names)

  managed_zone = google_dns_managed_zone.k8s_tfm.name
  name         = format("%s.%s", each.value, google_dns_managed_zone.k8s_tfm.dns_name)
  rrdatas      = [var.k8s_lb.address]
  ttl          = 300
  type         = "A"
}
