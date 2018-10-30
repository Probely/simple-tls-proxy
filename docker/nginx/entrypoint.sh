#!/bin/sh

NGINX_CONF_PATH="/etc/nginx"
NGINX_CONF_FILE="$NGINX_CONF_PATH/nginx.conf"
RESOLVER_PLACEHOLDER="{SYSTEM_RESOLVER}"

get_resolver() {
	local resolver=$(grep ^nameserver /etc/resolv.conf | head -1 | cut -d ' ' -f 2 | xargs)
	echo $resolver
}

is_template_file() {
	if [ "$1" = "" ]; then
		echo "";
		return;
	fi
	is_template=$(grep $RESOLVER_PLACEHOLDER $1 2> /dev/null)
	echo $is_template
}

[ ! -f ${NGINX_CONF_FILE}.orig ] && cp $NGINX_CONF_FILE ${NGINX_CONF_FILE}.orig
if [ "$(is_template_file ${NGINX_CONF_FILE}.orig)" != "" ]; then
	resolver=$(get_resolver)
	cp ${NGINX_CONF_FILE}.orig ${NGINX_CONF_FILE}
	sed -i s/$RESOLVER_PLACEHOLDER/$resolver/g ${NGINX_CONF_FILE}
fi

rm -f "$NGINX_CONF_PATH/letsencrypt.conf.d/reload" 2>/dev/null || true

exec "$@"
