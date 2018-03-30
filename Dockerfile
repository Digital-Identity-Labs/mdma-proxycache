FROM alpine:3.7

LABEL description="A simple Squid service to cache metadata and logo downloads for the MDMA metadata processor" \
      version="0.0.1" \
      maintainer="pete@digitalidentitylabs.com"

RUN apk add --update --no-cache \
    su-exec \
    sudo \
    squid

COPY source/squid.conf /etc/squid/squid.conf
COPY source/syslogd.conf /etc/syslogd.conf

RUN mkdir -p /etc/squid/squid.d && \
    ln -sf /dev/stdout /var/log/squid/access.log && \
    ln -sf /dev/stdout /var/log/squid/store.log && \
    ln -sf /dev/stdout /var/log/squid/cache.log && \
    chown -R squid:squid /var/log/squid && chmod -R u+rwx /var/log/squid

EXPOSE 3128

HEALTHCHECK --interval=1m --timeout=3s CMD squidclient -h localhost cache_object://localhost | grep "200 OK" || exit 1

ENTRYPOINT syslogd -f /etc/syslogd.conf && exec squid -NYCs -d 1