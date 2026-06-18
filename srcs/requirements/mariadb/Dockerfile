FROM debian:bookworm

RUN set -eux; \
	apt-get update && apt-get install -y \
	mariadb-server gettext-base \
	&& rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/lib/mysql/*

# Create the socket directory with correct permissions
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Copy the custom MariaDB configuration file into the container
COPY conf/mariadb.cnf /etc/mysql/conf.d/mariadb.cnf

# Copy initialization SQL scripts into the Docker container
COPY conf/init_db.sql /docker-entrypoint-initdb.d/

COPY conf/entry-point.sh /entry-point.sh

COPY tools/mariadb_healthcheck.sh /usr/local/bin/mariadb_healthcheck.sh

RUN chmod +x /entry-point.sh

RUN chmod +x /usr/local/bin/mariadb_healthcheck.sh


EXPOSE 3306

LABEL version="1.0"
LABEL description="MariaDB Server"

ENTRYPOINT ["/entry-point.sh"]
