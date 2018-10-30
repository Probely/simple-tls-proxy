#!/usr/bin/env python3

'''
Requests Let's encrypt certificates and generates configurations
from templates. Currently only Nginx is supported.
'''
import hashlib
import os
import subprocess
import sys
import time

from urllib.parse import urlparse

INSTALL_PATH = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
TEMPLATE_PATH = os.path.join(INSTALL_PATH, "templates")
VAR_PATH = os.path.join(INSTALL_PATH, "var")
LETSENCRYPT_CONFIG_PATH = "/etc/letsencrypt"
LETSENCRYPT_WEB_PATH = "/var/www/letsencrypt"
CONFIG_TEMPLATE = os.getenv("CONFIG_TEMPLATE", "nginx")
CONFIG_PATH = os.path.join(VAR_PATH, "config")
MIN_RENEWAL_INTERVAL = 3600


def request_certificate(hostname, email):
    ''' Requests certificate from Let's Encrypt. '''

    args = [
        "certbot", "certonly", "--webroot", "--email", email,
        "--noninteractive", "--agree-tos", "-w", LETSENCRYPT_WEB_PATH,
        "-d", hostname
    ]
    success = False
    try:
        ret = subprocess.check_output(args)
    except subprocess.CalledProcessError:
        print("Error requesting certificate.")
    else:
        success = ret == 0

    return success


def update_renewal_timestamp():
    now = int(time.time())
    path = os.path.join(CONFIG_PATH, "renewal.timestamp")
    write_file(path, now)


def write_file(path, data):
    with open(path, "w") as f:
        f.write("%s" % data)


def read_renewal_timestamp():
    last_renewal = 0
    path = os.path.join(CONFIG_PATH, "renewal.timestamp")
    data = read_file(path)
    if data is not None:
        last_renewal = int(data.strip())
    return last_renewal


def read_file(path):
    data = None
    try:
        with open(path, "r") as f:
            data = f.read()
    except (TypeError, ValueError):
        pass
    except FileNotFoundError:
        pass
    return data


def renew_certificates():
    ''' Renews all Let's Encrypt certificates. '''
    args = ["certbot", "renew", "--noninteractive"]
    try:
        subprocess.check_call(args)
    except subprocess.CalledProcessError:
        print("Error renewing certificates.")


def load_template(name):
    data = None
    try:
        path = os.path.join(TEMPLATE_PATH, name)
        with open(path, "r") as tmpl:
            data = tmpl.read()
    except EnvironmentError as enverr:
        print("Could not load %s: %s." % (path, enverr))
        data = None
    return data


def build_config(**kwargs):
    ''' Create a configuration for a specific hostname. '''
    kwargs["letsencrypt_config_path"] = LETSENCRYPT_CONFIG_PATH
    kwargs["letsencrypt_web_path"] = LETSENCRYPT_WEB_PATH
    bootstrap = kwargs['bootstrap']
    tmpl_suffix = "-bootstrap" if bootstrap else ""
    template_name = "%s%s.tmpl" % (CONFIG_TEMPLATE, tmpl_suffix)
    template = load_template(template_name)
    if template is None:
        return None
    config = template.format(**kwargs)
    return config


def create_config_file(**kwargs):
    ''' Adds a new configuration file. '''

    hostname = kwargs["hostname"]
    config = build_config(**kwargs)
    return write_hostname_config(config, hostname)


def write_hostname_config(config, hostname):
    if config is None:
        print("Could not load template while configuring %s." % hostname)
        return False

    conf_path = os.path.join(CONFIG_PATH, "%s.conf" % hostname)
    try:
        with open(conf_path, "w") as cfile:
            cfile.write(config)
    except EnvironmentError as enverr:
        print("Error creating configurating file for %s: %s." %
              (hostname, enverr))
        return False
    else:
        print("Written configuration file for %s." % hostname)
        return True


def certificate_installed(hostname):
    return os.path.isdir(
        "%s/live/%s" % (LETSENCRYPT_CONFIG_PATH, hostname))


def check_host_configuration(**kwargs):
    hostname = kwargs['hostname']
    path = "%s/%s.conf" % (CONFIG_PATH, hostname)
    try:
        with open(path, "rb") as config_file:
            cur_config = config_file.read()
    except EnvironmentError:
        return False

    new_config = build_config(**kwargs).encode('utf8')
    if new_config is None:
        return False
    cur_hash = hashlib.sha256(cur_config).digest()
    new_hash = hashlib.sha256(new_config).digest()

    return new_hash == cur_hash


def check_host(hostname):
    ''' Checks if a given hostname needs to be configured. '''

    changed = False

    try:
        hostname, backend = hostname.split(":", 1)
    except IndexError:
        print("Found malformed backend: %s." % hostname)
        return False

    try:
        urlparse(backend)
    except (TypeError, ValueError):
        print("Backend for %s is malformed: %s." % (hostname, backend))
        return False

    email = os.getenv("LETSENCRYPT_EMAIL")
    if email is None:
        print("Could not configure %s. Please set the LETSENCRYPT_EMAIL "
              "variable." % hostname)
        return False

    ciphersuites = os.getenv("TLS_CIPHER_SUITES")
    if ciphersuites is None:
        print("Could not configure %s. Please set the TLS_CIPHER_SUITES "
              "variable." % hostname)
        return False

    has_cert = certificate_installed(hostname)
    if not has_cert:
        request_certificate(hostname, email)
        has_cert = certificate_installed(hostname)

    match = check_host_configuration(hostname=hostname,
                                     backend=backend,
                                     ciphersuites=ciphersuites,
                                     bootstrap=not has_cert)

    if not match:
        changed = create_config_file(
            hostname=hostname,
            backend=backend,
            ciphersuites=ciphersuites,
            bootstrap=not has_cert)

    return changed


def remove_file(path):
    try:
        os.unlink(path)
    except EnvironmentError:
        pass


def main():
    hosts = os.getenv("PROXY_BACKEND_HOSTS")
    if not hosts:
        print("No hosts configured. Exiting...")
        return 0

    reload_file = os.path.join(CONFIG_PATH, "reload")
    hosts = hosts.split(",")
    for host in hosts:
        if check_host(host):
            now = "%s" % int(time.time())
            write_file(reload_file, now)

    now = int(time.time())
    last_renewal = read_renewal_timestamp()
    if now - last_renewal > MIN_RENEWAL_INTERVAL:
        renew_certificates()
        update_renewal_timestamp()

    data = read_file(reload_file)
    if data is not None:
        try:
            reload_ts = int(data.strip())
        except (TypeError, ValueError):
            remove_file(reload_file)
        else:
            if now - reload_ts < 300:
                print("A reload is required.")

    return 0


if __name__ == '__main__':
    sys.exit(main())
