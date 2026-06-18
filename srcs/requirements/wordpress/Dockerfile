FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2 php8.2-fpm php8.2-mysql php8.2-gd php8.2-zip php8.2-intl \
    mariadb-client curl wget unzip netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp

RUN mkdir -p /run/php /var/www/wordpress

COPY ./tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]
