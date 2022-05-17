#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'artisan' ]; then
	PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-production"
	if [ "$APP_ENV" = 'local' ]; then
		PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-development"
	fi

	ln -sf "$PHP_INI_RECOMMENDED" "$PHP_INI_DIR/php.ini"
	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX storage bootstrap/cache || true
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX storage bootstrap/cache || true

	if [ "$APP_ENV" != 'local' ]; then
		php artisan optimize
	fi
fi

exec docker-php-entrypoint "$@"
