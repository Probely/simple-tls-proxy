# Introduction

Please check the companion article first.

We created a Nginx TLS proxy container with modern TLS settings. The proxy can be placed in front of an existing HTTP website to enable HTTPS functionality with, hopefully, minimal hassle. You can think of it as a (limited) TLS terminator. You are free to change the configuration to better suit your needs, of course.

We provide two Terraform configurations that will automatically create the required cloud infrastructure and deploy the Nginx proxy container. This way, you can easily try out the TLS configurations on AWS or GCP.

Additionaly, we provide a docker-compose setup to be run on stand-alone virtual machine. This assumes that the VM has an assigned public IP, and is reachable on ports 80 and 443.

# Directory structure

```
.
├── deployments
│   ├── aws.............. Amazon Web Services Terraform files
│   ├── gcp.............. Google Cloud Plataform terraform files
│   └── stand-alone...... Stand-alone docker-compose configuration
├── docker
│   ├── nginx............ Let's Encrypt and TLS 1.3 enabled Nginx
│   └── tls-controller... Requests certificates and builds Nginx configs
├── LICENSE
├── Makefile
├── README.md
└── systemd.............. Systemd support files
```
