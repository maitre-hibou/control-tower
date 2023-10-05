#!/bin/bash

set -eu

envsubst '${APP_DOMAIN} ${COMPOSE_PROJECT_NAME}' < /etc/nginx/conf.d/app.conf.template > /etc/nginx/conf.d/app.conf

/docker-entrypoint.sh "$@"
