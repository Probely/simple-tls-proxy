data "template_file" "setup_script" {
  template = "${file("../instance-setup.sh")}"

  vars {
    letsencrypt_email   = "${var.letsencrypt_email}"
    tls_cipher_suites   = "${var.tls_cipher_suites}"
    proxy_backend_hosts = "${var.proxy_backend_hosts}"
  }
}

resource "aws_instance" "playground" {
  count         = "1"
  ami           = "${var.ami}"
  instance_type = "t2.nano"
  ebs_optimized = false
  key_name      = "playground-key"

  root_block_device {
    volume_type = "standard"
    volume_size = 20
  }

  subnet_id                   = "${aws_subnet.playground.id}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.playground.id}",
    "${aws_security_group.internet_out.id}",
  ]

  user_data = "${data.template_file.setup_script.rendered}"

  tags {
    Name = "tls-proxy-playground"
  }
}

resource "aws_key_pair" "playground" {
  key_name   = "playground-key"
  public_key = "${var.public_key}"
}
