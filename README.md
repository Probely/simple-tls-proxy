# Introduction

simple-tls-proxy is an Nginx-based TLS reverse proxy container with modern TLS settings and automatic certificate renewals. 

It can can be placed in front of an existing HTTP website to enable HTTPS functionality with, hopefully, minimal hassle. You can think of it as a (limited) TLS terminator. You are free to change the configuration to better suit your needs, of course.

We provide two Terraform configurations that will automatically create the required cloud infrastructure and deploy the TLS reverse proxy. This way, you can easily try out the TLS configurations on AWS or GCP.

We also detail the manual steps required to run the examples on a stand-alone virtual machine. This assumes that the VM has an assigned public IP, and is reachable on ports 80 and 443. 

Please note that these examples are meant to be used as proof-of-concept only. We are using "bleeding edge" package versions, since there is no official support for TLS 1.3 in the Nginx Docker images yet. The deployments run on a single-instance, and do not scale automatically. We advise you to not use this setup in production. We plan to provide scalable examples for this setup, Kubernetes, and Amazon ECS.

With the exception of the stand-alone example, familiarity with AWS or GCP is required. If you have any issue running any of our example deployments, please let us know in the comments section. We will do our best to help you out.

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

# Stand-alone deployment

## Requirements

This setup needs a dedicated virtual machine with the following requirements:
  * Docker;
  * Docker Compose;
  * Systemd (available in most Linux distributions);
  * Public IP;
  * Public DNS hostname, pointing to the IP above;
  * Ports 80 and 443 available;
  * Ports 80 and 443 reachable from the Internet.

## Procedure

Log in to the virtual machine and run the following commands:

```bash
git clone https://github.com/Probely/simple-tls-proxy
cd simple-tls-proxy
pushd deployments/stand-alone
cp sample/sample-deployment.env deployment.env
```

Next, edit the `deployment.env` file, and set the values according to your setup. Make sure that the `LETSENCRYPT_EMAIL` and `PROXY_BACKEND_HOSTS` variables are set correctly. 

Finally, run these commands:

```bash
popd
sudo make install
```

You can check the logs with:

```bash
# Let's Encrypt status messages
sudo journalctl -fu tls-proxy-controller
# Nginx logs
sudo journalctl -fu tls-proxy
```

If everything is configured correctly, you should see Let's Encrypt log entries confirming that the certificate was fetched correctly.

# Amazon Web Services deployment

## Requirements

  * A working AWS account;
  * Install the  AWS Command Line Interface (CLI);
  * Configure the AWS CLI;
  * Install Terraform.

## Procedure

Run these commands on the machine you have the AWS CLI and Terraform installed:

```bash
git clone https://github.com/Probely/simple-tls-proxy
cd deployments/aws
```

Edit the `default.auto.tfvars` file and set the following variables:
  * `letsencrypt_email`
  * `backend_hosts`
  * `public_key`

Specific guidance on how to choose proper values is provided inside the file.

When all required variables are set, run the following:

```bash
terraform apply
```

Wait for Terraform to finish. It can take a few minutes.

Next, you need to determine your instance's IP address.

```bash
# The region argument may not be needed, depending on your AWS CLI configuration.
PROXY_INSTANCE_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=tls-proxy-playground' --query 'Reservations[].Instances[].PublicIpAddress' --output text --region eu-west-3)
echo $PROXY_INSTANCE_IP
```

**Create a DNS entry with the hostname used in `proxy_backend_hosts` and point it to the IP address obtained above.**

Wait for 5–10 minutes. The virtual machine requires some time to initialize and install all required packages.

If you want to check the progress or just look around, you can log in to the virtual machine using the SSH key defined in `public_key`.

```bash
ssh centos@$PROXY_INSTANCE_IP -i /path/to/key
```

If the `yum` process is still running in the VM, wait a bit more for the installation to finish.

After the installation ends, you can check the logs with these commands:

```bash
# Let's Encrypt status messages
sudo journalctl -fu tls-proxy-controller
# Nginx logs
sudo journalctl -fu tls-proxy
```

# Google Cloud Platform deployment

## Requirements
  * A working GCP account;
  * Install the Google Cloud SDK;
  * Configure the Google Cloud SDK;
  * Install Terraform.

## Procedure

Run these commands on the machine you have the Google Cloud SDK and Terraform installed:

```bash
git clone https://github.com/Probely/simple-tls-proxy
cd deployments/gcp
```

Edit the default.auto.tfvars file and set the following variables.

  * `project_id`
  * `letsencrypt_email`
  * `backend_hosts`

Specific guidance on how to choose proper values is provided inside the file.

When all required variables are set, run the following:

```bash
terraform apply
```

Wait for Terraform to finish. It can take a few minutes.

Next, you need to determine your instance IP address.

```bash
gcloud --format="value(networkInterfaces[0].accessConfigs[0].natIP)" compute instances list --filter tls-proxy-playground
```

**Create a DNS entry with the hostname used in `proxy_backend_hosts` and point it to the IP address obtained above.**

Wait 5–10 minutes. The virtual machine requires some time to initialize and install all required packages.

If you want to check the progress or just look around, you can log in to the machine using `gcloud`. 

```bash
# The zone argument may not be needed, depending on your gcloud configuration.
gcloud compute ssh tls-proxy-playground --zone=europe-west4-a
```

If the `yum` process is still running in the VM, wait a bit more for the installation to finish.

After the installation ends, you can check the logs with these commands:

```bash
# Let's Encrypt status messages
sudo journalctl -fu tls-proxy-controller
# Nginx logs
sudo journalctl -fu tls-proxy
```
