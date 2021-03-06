NS = whw3
VERSION ?= latest
REPO = caddy
NAME = $(NS)/$(REPO)

.PHONY: purge clean start stop 

all:: build

plugins:
	./configure.sh

build: plugins
	./build.sh

push:
	docker push $(NAME)

shell:
	docker run --interactive --rm --tty $(REPO) /bin/bash

purge:
	./purge.sh

release: build
	make push -e VERSION=$(VERSION)

clean:
	./clean.sh

start:
	docker-compose up -d

stop:
	docker-compose down
