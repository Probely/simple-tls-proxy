data "template_file" "setup_script" {
  template = "${file("../instance-setup.sh")}"

  vars {
    letsencrypt_email   = "${var.letsencrypt_email}"
    tls_cipher_suites   = "${var.tls_cipher_suites}"
    proxy_backend_hosts = "${var.proxy_backend_hosts}"
  }
}

resource "google_compute_instance" "playground" {
  name         = "tls-proxy-playground"
  machine_type = "f1-micro"
  zone         = "${var.default_zone}"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    network = "${google_compute_network.playground.name}"

    # Request an external IP
    access_config = {
      nat_ip = ""
    }
  }

  tags = ["allow-ssh", "allow-web"]

  metadata {
    startup-script = "${data.template_file.setup_script.rendered}"
  }
}
