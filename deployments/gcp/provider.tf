provider "google" {
  project = "${var.project_id}"
  region  = "${var.default_region}"
  version = "~> 1.8"
}
