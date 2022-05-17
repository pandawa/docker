ARG PHP_VERSION=8.1

FROM php:${PHP_VERSION}-fpm-alpine AS pandawa-base

RUN set -eux; \
    apk add --no-cache \
        acl \
        file \
        gettext \
        git \
        busybox-extras \
        bind-tools \
        unzip \
        wget \
      ;

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin
RUN set -eux; \
    install-php-extensions \
        dom \
        iconv \
        intl \
        opcache \
        zip \
        curl\
    ;

RUN ln -s $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY php/conf.d/php.prod.ini $PHP_INI_DIR/conf.d/php.prod.ini

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV PATH="${PATH}:/root/.composer/vendor/bin"
ENV COMPOSER_ALLOW_SUPERUSER=1
ARG APP_ENV=prod

WORKDIR /srv/app

RUN set -eux; \
	mkdir -p \
		storage/logs \
		storage/framework/cache/data \
		storage/framework/sessions \
		storage/framework/views \
	;

FROM pandawa-base AS pandawa-swoole

RUN set -eux; \
	install-php-extensions \
		swoole \
	;

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
	CMD wget --no-verbose --tries=1 --spider http://localhost || exit 1

COPY php/entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php", "artisan", "octane:start", "--server=swoole", "--host=0.0.0.0", "--port=80", "--workers=2", "--task-workers=4"]
