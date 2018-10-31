variable "letsencrypt_email" {
  description = "Email used by Let's Encrypt to send notifications"
}

variable "tls_cipher_suites" {
  description = "A list of TLS cipher suites in OpenSSL format"
}

variable "proxy_backend_hosts" {
  description = "Hosts to be proxied. Format host:http://upstream[,host2:http://upstream2]. Example: tls.example.com:http://example.com"
}

variable "public_key" {
  description = "An SSH public key used to login on the proxy instance"
}

variable "cidr_block" {
  description = "The subnet range to use for our playground network"
}

variable "default_region" {
  description = "The default AWS region to use"
}

variable "default_zone" {
  description = "The default AWS availability zone to use"
}

variable "ami" {
  description = "The Amazon Machine Image (AMI) to use. This value is region-specific."
}
