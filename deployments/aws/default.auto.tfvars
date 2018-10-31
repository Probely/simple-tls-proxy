# Used by Let's Encrypt to send notifications
letsencrypt_email = ""

# Format: tls.host:http://upstream[,tls.host2:http://upstream2]
# Example: tls.example.com:http://example.com
# Example: tls.example.com:http://example.com,tls2.example.com:http://some.other.site
proxy_backend_hosts = "tls.example.com:http://example.com"

# An SSH public key. Used to log in to the virtual machine, with the user "centos".
# At this time, AWS does not seem to support ed25519 keys, unfortunately.
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJt8rQ6iFlKgTu7FQxh/aA7SlD/ZXzfbyLGys3Q6O+BAkVw3ncdPav6poDuJvsfuQPFWc3vi07LT+IkvMY3gTbkZ/SKsSjbxvUolAljYHBo+38Np5xUeqC820ZhiTbnntj9zJz9L4ufx6AtIr+1yJiGtCEScR1OYT0Mq+c53vrZCn0N52AyXf1s9JIJwx90ymvWfZIKLklkgOKfuSbcFnDBsjZVk83MzxOvCeDgnB3qLdWlpUvU1813gLmJn94XymET/H8cfDuP9G6LaqL4TOjXeQnUnUk3mrBDbgQxR3Yx2sdLg5cWuO3cs6vRIlp3C0pvw9CCb9JX7n4UBrEZ989 user@local"

tls_cipher_suites = "TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256"

cidr_block = "172.30.255.0/28"
default_region = "eu-west-3"
default_zone = "eu-west-3a"
# The AMI is region-specific. If using another region, search for the correct AMI with: 
# aws --region <region> ec2 describe-images --owners aws-marketplace \
#	--filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce | \
#	grep CreationDate -A 1
ami = "ami-6276c71f"


