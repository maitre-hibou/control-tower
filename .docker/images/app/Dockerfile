FROM        php:8.2-fpm AS base
LABEL       maintainer="Arnaud P <arnaud@xpressive.io>"

ARG         USER_ID=1000

ENV         COMPOSER_HOME=/usr/local/lib/composer

RUN         apt update && apt install -y curl libcurl4-openssl-dev libxml2-dev libzip-dev netcat-traditional unzip wget zip

RUN         usermod -u ${USER_ID} www-data && \
            groupmod -g ${USER_ID} www-data

RUN         docker-php-ext-install curl simplexml zip

RUN         mkdir -p ${COMPOSER_HOME}
RUN         chown -R www-data:www-data $COMPOSER_HOME
COPY        --from=composer/composer:2.6 /usr/bin/composer /usr/local/bin/composer

COPY        .docker/images/app/conf/docker.php.ini /usr/local/etc/php/conf.d/docker.php.ini

RUN         rm -rf /var/www && mkdir -p /var/www
RUN         chown -R www-data:www-data /var/www

WORKDIR     /var/www
VOLUME      /var/www

EXPOSE 9000

HEALTHCHECK --interval=10s --timeout=10s --retries=5 \
  CMD ["nc", "-z", "-v", "localhost", "9000"]

FROM        base AS app

ENV         APP_ENV=dev

RUN         pecl install apcu
RUN         docker-php-ext-install bcmath intl opcache
RUN         docker-php-ext-enable apcu opcache

COPY        .docker/images/app/entrypoint.sh /usr/local/bin/docker-php-entrypoint.my

COPY        --chown=www-data:www-data . /var/www/

ENTRYPOINT  ["/usr/local/bin/docker-php-entrypoint.my"]
CMD         ["php-fpm"]
