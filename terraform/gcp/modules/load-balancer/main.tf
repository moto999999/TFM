# https://cloud.google.com/load-balancing/docs/tcp/ext-tcp-proxy-lb-tf-examples

# reserved IP address
resource "google_compute_global_address" "k8s_lb" {
  name = "lb-k8s"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "lb_k8s_control_plane" {
  name                  = "lb-control-plane-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "6443"
  target                = google_compute_target_tcp_proxy.tcp_proxy_control_plane.id
  ip_address            = google_compute_global_address.k8s_lb.id
}

resource "google_compute_target_tcp_proxy" "tcp_proxy_control_plane" {
  name            = "api-server-proxy-health-check"
  backend_service = google_compute_backend_service.k8s_lb_api_server.id
}

# backend service
resource "google_compute_backend_service" "k8s_lb_api_server" {
  name                  = "tcp-proxy-api-server-backend-service"
  protocol              = "TCP"
  port_name             = "api-server"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 9
  health_checks         = [google_compute_health_check.api_server.id]
  backend {
    group           = var.mig_control_plane.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "api_server" {
  name                = "tcp-proxy-health-check"
  timeout_sec         = 20
  check_interval_sec  = 20
  healthy_threshold   = 2
  unhealthy_threshold = 5

  tcp_health_check {
    port = "6443"
  }
}

# SSL certificate
resource "google_compute_ssl_certificate" "k8s_apps" {
  name        = "k8s-apps-certificate"
  private_key = file(var.certificate_private_key)
  certificate = file(var.certificate)
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "lb_nginx" {
  name                  = "lb-nginx"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.nginx.id
  ip_address            = google_compute_global_address.k8s_lb.id
}

resource "google_compute_target_https_proxy" "nginx" {
  name             = "nginx-health-check"
  ssl_certificates = [google_compute_ssl_certificate.k8s_apps.id]
  url_map          = google_compute_url_map.lb_nginx.id
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "lb_nginx_http" {
  name                  = "lb-nginx-http"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.nginx_http.id
  ip_address            = google_compute_global_address.k8s_lb.id
}

resource "google_compute_target_http_proxy" "nginx_http" {
  name             = "nginx-health-check"
  url_map          = google_compute_url_map.lb_nginx.id
}

# backend service
resource "google_compute_backend_service" "k8s_lb_nginx" {
  name             = "backend-nginx"
  protocol         = "HTTP"
  port_name        = "nginx"
  timeout_sec      = 30
  enable_cdn       = true
  compression_mode = "DISABLED"
  health_checks    = [google_compute_health_check.nginx.id]
  backend {
    group           = var.mig_worker.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
    capacity_scaler = 1.0
  }
  cdn_policy {
    cache_key_policy {
      include_host         = "true"
      include_protocol     = "true"
      include_query_string = "true"
    }

    cache_mode                   = "CACHE_ALL_STATIC"
    client_ttl                   = "3600"
    default_ttl                  = "3600"
    max_ttl                      = "86400"
    negative_caching             = "false"
    serve_while_stale            = "0"
    signed_url_cache_max_age_sec = "0"
  }
}

resource "google_compute_health_check" "nginx" {
  name                = "nginx-health-check"
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = var.http_ingress_nodeport
    request_path = "/healthz"
  }
}

resource "google_compute_url_map" "lb_nginx" {
  default_service = google_compute_backend_service.k8s_lb_nginx.id

  host_rule {
    hosts        = ["*.${var.dns_name}"]
    path_matcher = "path-matcher-1"
  }

  name = "lb-nginx"

  path_matcher {
    default_service = google_compute_backend_service.k8s_lb_nginx.id
    name            = "path-matcher-1"

    path_rule {
      paths   = ["/"]
      service = google_compute_backend_service.k8s_lb_nginx.id
    }
  }

}
