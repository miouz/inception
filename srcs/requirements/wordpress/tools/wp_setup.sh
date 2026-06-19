#!/bin/bash

# the setup : 
# -wait for MariaDB
# -install WordPress files if the volume is empty
# -create wp-config.php with the right DB settings
# -and finally start PHP-FPM in the foreground
#

set -eux 

DB_PASSWORD="$(cat /run/secrets/db_password)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

until mariadb -h mariadb -u"$MARIADB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" "$MARIADB_DATABASE" >/dev/null 
do
	sleep 2
done

if [ ! -f wp-config.php ]; then
	wp core download --allow-root

	wp config create --allow-root \
		--dbname="$MARIADB_DATABASE" \
		--dbuser="$MARIADB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST"

	wp core install --allow-root \
		--url="$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL"

	wp user create --allow-root \
		"$WP_USER" "$WP_USER_EMAIL" \
		--user_pass="$WP_USER_PASSWORD"

	chown -R www-data:www-data /var/www/wordpress
fi

sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

exec php-fpm8.2 -F
