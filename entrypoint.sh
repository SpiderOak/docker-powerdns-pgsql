#!/bin/bash
# vim:ts=2 sw=2
set -e

sed -i "s|^# version-string=.*|version-string=HappyDNS|" /etc/powerdns/recursor.conf
sed -i "s|^# cache-ttl=.*|cache-ttl=300|" /etc/powerdns/pdns.conf
sed -i "s|^# disable-axfr=no|disable-axfr=yes|" /etc/powerdns/pdns.conf
sed -i "s|^# guardian=no|guardian=yes|" /etc/powerdns/pdns.conf
sed -i "s|^# max-queue-length=.*|max-queue-length=25000|" /etc/powerdns/pdns.conf
sed -i "s|^# negquery-cache-ttl=.*|negquery-cache-ttl=300|" /etc/powerdns/pdns.conf
sed -i "s|^# recursive-cache-ttl=.*|recursive-cache-ttl=60|" /etc/powerdns/pdns.conf
sed -i "s|^# version-string=.*|version-string=HappyDNS|" /etc/powerdns/pdns.conf

[ "$ALLOW_RECURSION" ] && \
	(
		sed -i "s|^# allow-from=.*|allow-from=$ALLOW_RECURSION|" /etc/powerdns/recursor.conf
		[ "$FORWARD_ZONES_FILE" ] && sed -i "s|^# forward-zones-file=.*|forward-zones-file=$FORWARD_ZONES_FILE|" /etc/powerdns/recursor.conf
		sed -i "s|^# local-port=.*|local-port=5300|" /etc/powerdns/pdns.conf
		echo local-address=127.0.0.1 >> /etc/powerdns/pdns.conf
		echo local-address=0.0.0.0 >> /etc/powerdns/recursor.conf
		ln -s /etc/service-available/pdns-recursor /etc/service/pdns-recursor
	)

cat <<EOF > /etc/powerdns/pdns.d/pdns.local.gpgsql.conf
launch+=gpgsql
gpgsql-host=${PG_HOST:?}
gpgsql-port=${PG_PORT:-}
gpgsql-dbname=${PG_DBNAME:?}
gpgsql-user=${PG_USER:?}
gpgsql-password=${PG_PASS:?}
gpgsql-dnssec=yes
EOF

shutdown() {
  sv -w 60 force-stop /etc/service/*
  if [ -e "/proc/$1" ]; then
    kill -HUP "$1"
    wait "$1"
  fi
  exit
}

if [ $# -eq 0 ]; then
  exec /usr/sbin/runsvdir-start &
  pid=$!
  trap "shutdown $pid" SIGTERM SIGHUP SIGINT
  wait $pid
else
  exec "$@"
fi
