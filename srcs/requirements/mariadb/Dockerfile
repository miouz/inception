FROM debian:bullseye
RUN apt-get update
RUN apt-get install -y mariadb-server

# Create the socket directory with correct permissions
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Copy the custom MariaDB configuration file into the container
COPY conf/mariadb.cnf /etc/mysql/conf.d/

# Copy initialization SQL scripts into the Docker container
COPY conf/ /docker-entrypoint-initdb.d/

EXPOSE 3306

LABEL version="1.0"
LABEL description="MariaDB Server"

CMD ["mysqld"]
