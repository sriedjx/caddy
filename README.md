# caddy
Caddy installer for Docker on RPI

A download based installer because building from sources doesn't always work.  The [mholt/caddy](https://github.com/mholt/caddy) often becomes unstable between releases.
Runtime image utilizes `s6-setuidgid` to drop privileges
***Caddy will run with UID 82 (www-data) and not as root!***

## Build Instructions
```
git clone https://github.com/whw3/caddy-http.git
cd caddy-http
make clean
make
```
## Runtime 
1. start
...  `make start`
2. stop
... `make stop`


### Requirements
* jq
* docker-compose

No worrys `configure.sh` will install them if missing
