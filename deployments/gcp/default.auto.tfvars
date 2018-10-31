# This is your Google Cloud project id. You can check it on the web console, or by running the following command:
# gcloud config list --format 'value(core.project)' 2>/dev/null
project_id = ""
# Used by Let's Encrypt to send notifications
letsencrypt_email = ""

tls_cipher_suites = "TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256"

# Format: tls.host:http://upstream[,tls.host2:http://upstream2]
# Example: tls.example.com:http://example.com
# Example: tls.example.com:http://example.com,tls2.example.com:http://some.other.site
proxy_backend_hosts = "tls.example.com:http://example.com"

default_region = "europe-west4"
default_zone = "europe-west4-a"

