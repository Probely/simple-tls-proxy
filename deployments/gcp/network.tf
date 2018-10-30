resource "google_compute_network" "playground" {
  name                    = "tls-proxy-playground"
  auto_create_subnetworks = true
}
