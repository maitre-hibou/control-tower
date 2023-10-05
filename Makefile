-include .env

IS_DOCKER_COMPOSE_ARG = $(docker compose ps 2> /dev/null; echo $$?)
ifeq ($(IS_DOCKER_COMPOSE_ARG),1)
	DOCKER_COMPOSE = docker-compose
else
	DOCKER_COMPOSE = docker compose
endif

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
