#!/bin/bash

set -e

COMPOSER_FLAGS="--no-progress --prefer-dist"
if [[ ${APP_ENV:="dev"} == "prod" ]]; then
    COMPOSER_FLAGS="--no-dev --optimize-autoloader --no-progress --prefer-dist"
fi

composer install ${COMPOSER_FLAGS}

chown -R www-data:www-data /var/www
chown -R www-data:www-data ${COMPOSER_HOME:="/usr/local/lib/composer"}

/usr/local/bin/docker-php-entrypoint "$@"
