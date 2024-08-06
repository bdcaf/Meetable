FROM composer:2 AS composer-build

WORKDIR /build
COPY . /build/
RUN rm -rf docker-root
RUN composer install  --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-progress

FROM alpine:3.20
ARG phpv=82
RUN apk add --no-cache \
    nginx \
    php${phpv} \
    php${phpv}-bcmath \
    php${phpv}-common \
    php${phpv}-curl \
    php${phpv}-dom \
    php${phpv}-fileinfo \
    php${phpv}-fpm \
    php${phpv}-iconv \
    php${phpv}-mbstring \
    php${phpv}-pcntl \
    php${phpv}-pdo \
    php${phpv}-pdo_mysql \
    php${phpv}-pdo_pgsql \
    php${phpv}-pdo_sqlite \
    php${phpv}-pecl-imagick \
    php${phpv}-pecl-redis \
    php${phpv}-phar \
    php${phpv}-simplexml \
    php${phpv}-tokenizer \
    php${phpv}-xml \
    php${phpv}-xmlwriter \
    supervisor;

COPY --link --from=composer-build /build /var/www/meetable
COPY docker-root/ /

WORKDIR /var/www/meetable/
ENV APP_BASE_PATH=/var/www/meetable

# fix volume permissions
RUN chgrp -R nginx /run /var/lib  && \
    chmod -R g+w /run /var/lib && \
    chown -R nginx /var/www/meetable/storage

VOLUME /var/www/meetable/storage

EXPOSE 8000
USER nginx:nginx

CMD ["/usr/bin/supervisord"]
