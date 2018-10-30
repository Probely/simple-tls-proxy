resource "google_compute_firewall" "allow_ssh" {
  name    = "playground-allow-ssh"
  network = "${google_compute_network.playground.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow_web" {
  name    = "playground-allow-web"
  network = "${google_compute_network.playground.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-web"]
}
