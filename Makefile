WEB_PORT=80
ONYX_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)
PA11Y_PORT=$(shell echo $(WEB_PORT)+1001 | bc)

export WEB_PORT
export DEV_SERVER_PORT=$(shell echo $(WEB_PORT)+1000 | bc)
export USER_ID=$(shell id -u)
export GROUP_ID=$(shell id -g)
export PA11Y_PORT

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
	(docker stop asqatasun) || true

down:
	docker-compose -f docker/docker-compose.yml down
	(docker down asqatasun) || true

build:
	docker-compose -f docker/docker-compose.yml build

a11y:
	$(info Go to http://localhost:${PA11Y_PORT}/asqatasun/ and log in with me@my-email.org / myAsqaPassword to run complete tests)
	(docker run --name asqatasun -d -p "${PA11Y_PORT}:8080"  asqatasun/asqatasun) || true
	docker run -it --rm \
		-e "DEV_SERVER_PORT=${DEV_SERVER_PORT}" \
		-p "${DEV_SERVER_PORT}:${DEV_SERVER_PORT}" \
		-u ${USER_ID}:${GROUP_ID} \
		-v ${ONYX_DIR}:/usr/src/app \
		--net="host" \
		-w /usr/src/app \
		node:7 \
		npm run pa11y -- $(filter-out $@ e2e,$(MAKECMDGOALS))

.PHONY: install config install-deps install-back-deps install-front-deps update-deps phpunit clean remove-deps uninstall dumpautoload up stop down build webpack webpack-dev webpack-watch npm install-front-deps
