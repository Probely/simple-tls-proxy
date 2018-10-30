#!/bin/bash -e
#
# Initialize instances for the whole team to access.
# This should really be an Ansible script, or something, but
# we have to normalize the enviroment there first...
#

export SETUP_DONE_PATH="/.setup-done"

if [ -f "$SETUP_DONE_PATH" ]; then
    exit 0;
fi

if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs root privileges to run!" >&2
    exit 1
fi

if ! cat /etc/os-release | egrep -q "^ID_LIKE=\"rhel fedora\"$"; then
    echo "Our other VMs are RHEL-based, this one must be too!" >&2
    exit 1
fi

cd "$(dirname "$0")"
yum -q -y update || true
CENTOS_RELEASE=$(rpm -q --queryformat '%{VERSION}' centos-release)

rpm --import "/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-$CENTOS_RELEASE" || true
yum -q -y --nogpgcheck install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${CENTOS_RELEASE}.noarch.rpm" || true
rpm --import "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${CENTOS_RELEASE}" || true
yum -q -y install chrony git make \
	net-tools yum-utils \
	lsof \
	pv ntpdate vim \
	lynx wget unzip bind-utils || true
yum -q -y --nogpgcheck install "https://centos${CENTOS_RELEASE}.iuscommunity.org/ius-release.rpm" || true
rpm --import "/etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY" || true

# Docker
yum -y remove docker \
	docker-client \
	docker-client-latest \
	docker-common \
	docker-latest \
	docker-latest-logrotate \
	docker-logrotate \
	docker-selinux \
	docker-engine-selinux \
	docker-engine || true

yum -y install yum-utils \
	device-mapper-persistent-data \
	lvm2 curl

yum-config-manager \
	--add-repo \
	https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce docker-compose

systemctl enable docker
systemctl start docker

TMP_INSTALL_DIR=$(mktemp -d)
pushd $TMP_INSTALL_DIR
git clone https://github.com/Probely/simple-tls-proxy.git
pushd simple-tls-proxy
make install

cat << EOF > /etc/tls-proxy/system.env
LETSENCRYPT_EMAIL=${letsencrypt_email}
TLS_CIPHER_SUITES=${tls_cipher_suites}
PROXY_BACKEND_HOSTS=${proxy_backend_hosts}
EOF

popd
popd
rm -rf $TMP_INSTALL_DIR

touch $SETUP_DONE_PATH
