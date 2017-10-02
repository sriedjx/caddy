FROM whw3/alpine:latest
EXPOSE 80 443 2015
ENTRYPOINT ["/init"]
WORKDIR /srv
# ensure www-data user exists
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -H -h /srv -G www-data www-data && exit 0 ; exit 1
# 82 is the standard uid/gid for "www-data" in Alpine

COPY rootfs /
RUN apk-install ca-certificates libcap
RUN setcap cap_net_bind_service=+ep /usr/bin/caddy \
    && /usr/bin/caddy -version
