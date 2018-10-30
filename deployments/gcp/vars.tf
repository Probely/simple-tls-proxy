variable "project_id" {
  description = "The GCP project id where the resources will be created"
}

variable "default_region" {
  description = "The default GCP region to use"
  default     = "europe-west4"
}

variable "default_zone" {
  description = "The default GCP zone to use"
  default     = "europe-west4-a"
}

variable "letsencrypt_email" {
  description = "Email used by Let's Encrypt to send notifications"
}

variable "tls_cipher_suites" {
  description = "A list of TLS cipher suites in OpenSSL format"
}

variable "proxy_backend_hosts" {
  description = "Hosts to be proxied. Format host:http://upstream[,host2:http://upstream2]. Example: tls.example.com:http://example.com"
}
