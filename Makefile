-include .env

IS_DOCKER_COMPOSE_ARG = $(docker compose ps 2> /dev/null; echo $$?)
ifeq ($(IS_DOCKER_COMPOSE_ARG),1)
	DOCKER_COMPOSE = docker-compose
else
	DOCKER_COMPOSE = docker compose
endif

PHP 		= $(DOCKER_COMPOSE) exec -u www-data app php
PHP_TEST 	= $(DOCKER_COMPOSE) run --rm -u www-data -e APP_ENV=test app php
COMPOSER 	= $(PHP) /usr/local/bin/composer
SF_CONSOLE 	= $(PHP) bin/console

.DEFAULT_GOAL := help

help: 				## Show this message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


install: build up	## Initialize and start project
	@- docker network connect $(COMPOSE_PROJECT_NAME)_external ${LOCAL_PROXY_CONTAINER_NAME}

.PHONY: help install

##@ Docker stack

build: 				## Build project images
	@$(DOCKER_COMPOSE) pull --parallel --quiet --ignore-pull-failures 2> /dev/null
	@$(DOCKER_COMPOSE) build --pull --build-arg USER_ID=$(shell id -u)

down: 				## Stop and destroy project containers
	@- docker network disconnect ${COMPOSE_PROJECT_NAME}_external ${LOCAL_PROXY_CONTAINER_NAME}
	@$(DOCKER_COMPOSE) kill
	@$(DOCKER_COMPOSE) down -v --remove-orphans --rmi=all

stop: 				## Stop project containers
	@$(DOCKER_COMPOSE) stop

up: 				## Start project containers
	@$(DOCKER_COMPOSE) up -d --force-recreate

.PHONY: build down stop up

##@ Application

cache: 				## Clear Symfony cache
	@$(SF_CONSOLE) cache:clear ${c}

composer: 			## Execute composer within app container
	@$(COMPOSER) ${c}

console: 			## Execute Symfony console within app container
	@$(SF_CONSOLE) ${c}

.PHONY: composer console

##@ Tests & QA

lint: lint-twig lint-yaml	## Lint yaml & Twig project files

lint-twig:
	@$(PHP_TEST) bin/console lint:twig templates/

lint-yaml:
	@$(PHP_TEST) bin/console lint:yaml config/

phpcs:
	@$(PHP_TEST) vendor/bin/php-cs-fixer fix --config=config/.php-cs-fixer.dist.php --dry-run --diff --verbose --allow-risky=yes --using-cache=no

phpunit: 					## Run project PHPUnit tests suites
	@$(PHP_TEST) bin/phpunit --do-not-cache-result -c config/.phpunit.xml.dist ${c}

psalm: 						## Run Psalm static code analysis
	@$(PHP_TEST) vendor/bin/psalm --no-cache -c config/.psalm.xml.dist ${c}

qa: lint phpcs 				## Run project QA tools

tests: phpunit psalm		## Run project tests tools

.PHONY: lint lint-twig lint-yaml phpcs phpunit psalm tests
