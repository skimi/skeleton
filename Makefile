WEB_PORT=80
ONYX_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)
DEV_SERVER_PORT=$(shell echo $(WEB_PORT)+1000 | bc)

export WEB_PORT
export DEV_SERVER_PORT
export USER_ID
export GROUP_ID
export APP_URL

-include vendor/onyx/core/wizards.mk
include qa.mk

all: install phpunit

install: var install-deps config webpack

var:
	mkdir -m a+w var

config: karma
	./karma hydrate

karma:
	$(eval LATEST_VERSION := $(shell curl -L -s -H 'Accept: application/json' https://github.com/niktux/karma/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/'))
	@echo "Latest version of Karma is ${LATEST_VERSION}"
	wget -O karma -q https://github.com/Niktux/karma/releases/download/${LATEST_VERSION}/karma.phar
	chmod 0755 karma

install-deps: install-back-deps install-front-deps

install-back-deps: composer.phar
	php composer.phar install --ignore-platform-reqs

update-back-deps: composer.phar
	php composer.phar update

composer.phar:
	curl -sS https://getcomposer.org/installer | php

dumpautoload: composer.phar
	php composer.phar dumpautoload

phpunit: vendor/bin/phpunit
	vendor/bin/phpunit

vendor/bin/phpunit: install-deps

install-front-deps: npm

npm:
	docker run -it --rm \
		-v ${ONYX_DIR}:/usr/src/app \
		-u ${USER_ID}:${GROUP_ID} \
		-w /usr/src/app node:7 \
		npm install

webpack:
	rm -f www/assets/*
	docker run -it --rm \
		-v ${ONYX_DIR}:/usr/src/app \
		-u ${USER_ID}:${GROUP_ID} \
		-w /usr/src/app node:7 \
		npm run build

webpack-dev:
	rm -f www/assets/*
	docker run -it --rm \
		-v ${ONYX_DIR}:/usr/src/app \
		-u ${USER_ID}:${GROUP_ID} \
		-w /usr/src/app node:7 \
		npm run build:dev

webpack-watch:
	docker run -it --rm \
		-e "DEV_SERVER_PORT=${DEV_SERVER_PORT}" \
		-p "${DEV_SERVER_PORT}:${DEV_SERVER_PORT}" \
		-u ${USER_ID}:${GROUP_ID} \
		-v ${ONYX_DIR}:/usr/src/app \
		-w /usr/src/app node:7 \
		npm run watch

e2e: e2e-local

e2e-local: e2e-clean
	docker run --name selenium-chrome -d -p 4444:4444 --net="host" selenium/standalone-chrome:3.0.1
	docker run -it --rm \
		-v ${ONYX_DIR}:/usr/src/app \
		-u ${USER_ID}:${GROUP_ID} \
		-e WEB_PORT=$(WEB_PORT) \
		-e APP_URL=$(APP_URL) \
		-w /usr/src/app \
		--net="host" \
		node:7 \
		npm run e2e:local -- $(filter-out $@ e2e,$(MAKECMDGOALS))
	docker rm -f selenium-chrome

e2e-live: e2e-clean
	docker run -it --rm \
		-v ${ONYX_DIR}:/usr/src/app \
		-u ${USER_ID}:${GROUP_ID} \
		-e WEB_PORT=$(WEB_PORT) \
		-e APP_URL=$(APP_URL) \
		-w /usr/src/app \
		--net="host" \
		node:7 \
		npm run e2e:all -- $(filter-out $@ e2e,$(MAKECMDGOALS))

e2e-clean:
	rm -rf tests_output
	(docker rm -f selenium-chrome 2> /dev/null) || true

uninstall: clean remove-deps
	rm -rf www/assets
	rm -f composer.lock
	rm -f config/built-in/*.yml

clean:
	rm -f karma
	rm -f composer.phar

remove-deps:
	rm -rf vendor
	rm -rf node_modules

up:
	docker-compose -f docker/docker-compose.yml up -d

stop:
	docker-compose -f docker/docker-compose.yml stop

down:
	docker-compose -f docker/docker-compose.yml down

build:
	docker-compose -f docker/docker-compose.yml build

.PHONY: install config install-deps install-back-deps install-front-deps update-deps phpunit clean remove-deps uninstall dumpautoload up stop down build webpack webpack-dev webpack-watch npm install-front-deps
