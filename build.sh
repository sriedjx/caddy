#!/bin/bash
BASEDIR=$(cd "$( dirname "$0" )" && pwd)
cd "$BASEDIR"
datadir="$BASEDIR/data/srv"
rootfs="$BASEDIR/rootfs"

function get_caddy_version()
{
[[ -f caddy-tags.json ]] && rm caddy-tags.json
curl "https://api.github.com/repos/mholt/caddy/tags" > caddy-tags.json
eval "$(jq -r '.[0] | @sh "version=\(.name)"' caddy-tags.json )"
export version=$version
}
function download_caddy()
{
    mkdir -p "$rootfs"/usr/bin
    curl --silent --show-error --fail --location \
        --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
        "https://caddyserver.com/download/linux/arm7?plugins=${_plugins}" \
        | tar --no-same-owner -C "$rootfs"/usr/bin/ -xz caddy 
    chmod 0755 "$rootfs"/usr/bin/caddy
}
function check_caddy()
{
    local _version=$(<VERSION)
    local _plugins=$(<plugins)
    if [[ "$version" != "$_version" ]]; then
        echo "$version" > VERSION
        download_caddy
    fi
}
### MAIN ###
get_caddy_version
if [[ -e "$rootfs"/usr/bin/caddy ]]; then 
    check_caddy
else
    download_caddy
fi
if (whiptail --title "Enable PHP" --yesno "Should I enable PHP for this container?" 8 58) then
    version="php"
    cp "$BASEDIR"/php.Dockerfile "$BASEDIR"/Dockerfile
    cp -a "$BASEDIR"/services.d/* "$rootfs"/etc/services.d/
    [[ -e "$datadir"/htdocs/index.html ]] && rm "$datadir"/htdocs/index.html
    echo "<?php phpinfo(); ?>" > "$datadir"/htdocs/index.php
    cp "$BASEDIR"/php.Caddyfile "$datadir"/caddy/Caddyfile
else
    [[ "$?" = 255 ]] && exit 1
    cp latest.Dockerfile Dockerfile
    if [[ -d "$rootfs"/etc/services.d/php ]]; then
        rm -rf "$rootfs"/etc/services.d/php
        [[ -d "$datadir"/etc/services.d/php ]] && rm -rf "$datadir"/etc/services.d/php
        rm "$datadir"/htdocs/index.php
    fi
    cp "$BASEDIR"/index.html "$datadir"/htdocs/
    cp "$rootfs"/etc/Caddyfile "$datadir"/caddy/
fi
cat << EOF > docker-compose.yml
version: '3'

services:
   caddy:
      image: whw3/caddy:$version
      build: .
      ports:
      - "8080:80"
      - "4443:443"
      - "2015:2015"
      volumes:
      - ./data/srv:/srv
EOF
docker-compose build --force-rm
[[ "$version" != "php" ]] && docker tag whw3/caddy:$version whw3/caddy:latest
