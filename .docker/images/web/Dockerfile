FROM        nginx:mainline
LABEL       maintainer="Arnaud P <arnaud@xpressive.io>"

ARG         USER_ID=1000

RUN         apt update && apt install -y netcat-traditional

RUN         usermod -u ${USER_ID} www-data && \
            groupmod -g ${USER_ID} www-data

COPY        .docker/images/web/conf/app.conf.template /etc/nginx/templates/

VOLUME      /var/www
WORKDIR     /var/www

EXPOSE      80 443

HEALTHCHECK --interval=10s --timeout=10s --retries=5 \
  CMD ["nc", "-z", "-v", "localhost", "80"]
