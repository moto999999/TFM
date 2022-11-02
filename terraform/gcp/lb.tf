# https://cloud.google.com/load-balancing/docs/tcp/ext-tcp-proxy-lb-tf-examples

# reserved IP address
resource "google_compute_global_address" "k8s_lb_control_plane" {
  name = "lb-control-plane"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "lb_k8s_control_plane" {
  name                  = "lb-control-plane-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "6443"
  target                = google_compute_target_tcp_proxy.tcp_proxy_control_plane.id
  ip_address            = google_compute_global_address.k8s_lb_control_plane.id
}

resource "google_compute_target_tcp_proxy" "tcp_proxy_control_plane" {
  name            = "api-server-proxy-health-check"
  backend_service = google_compute_backend_service.k8s_lb_api_server.id
}

# backend service
resource "google_compute_backend_service" "k8s_lb_api_server" {
  name                  = "tcp-proxy-api-server-backend-service"
  protocol              = "TCP"
  port_name             = "tcp"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.api_server.id]
  backend {
    group           = google_compute_region_instance_group_manager.mig_control_plane.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "api_server" {
  name               = "tcp-proxy-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "6443"
  }
}
