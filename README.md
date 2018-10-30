# Introduction

Please check the companion article first.

This repository provides several deployment options for an HTTPS proxy that sits in front of an existing HTTP service. This will automatically make the existing service HTTPS-enabled with hopefully minimal hassle. You can think of it as a very (very) limited TLS terminator. You are free to change the configurations to better suit your needs, of course.

We provide two Terraform configurations that will automatically create the required cloud infrastructure and the proxy itself. This way, you can easily try out the modern TLS configurations on AWS or GCP.

Alternatively, we also provide a docker-compose file to be run on a stand-alone virtual machine. This assumes that the VM has an assigned public IP, and is reachable on ports 80 and 443. 

# Directory structure

```
.
├── deployments
│   ├── aws.............. Amazon Web Services Terraform files
│   ├── gcp.............. Google Cloud Plataform terraform files
│   └── stand-alone...... Stand-alone docker-compose configuration
├── docker
│   ├── tls-controller... Requests certificates and builds Nginx configs
│   └── nginx............ Let's Encrypt and TLS 1.3 enabled Nginx
├── LICENSE
└── README.md
```
