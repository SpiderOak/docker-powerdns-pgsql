FROM ubuntu:xenial

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    dnsutils \
    pdns-backend-pgsql \
    pdns-recursor \
    pdns-server \
    runit \
&& rm -rf /var/lib/apt/lists/* \
&& rm \
    /etc/powerdns/bindbackend.conf \
    /etc/powerdns/pdns.d/pdns.local.conf \
    /etc/powerdns/pdns.d/pdns.simplebind.conf \
&& true

COPY etc/ /etc/
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
