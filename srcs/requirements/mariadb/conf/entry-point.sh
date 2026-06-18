#!/bin/bash
#if any command fails, stop the script directly
set -eux

# Read secrets
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"

# Bootstrap only if data directory is empty (first start)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."

    # Initialize the data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Start a temporary instance to run setup SQL
    mysqld --user=mysql --skip-networking &
    MYSQL_PID=$!

    # Wait for it to be ready
    until mariadb -u root -e "SELECT 1;" > /dev/null 2>&1; do
        sleep 1
    done

    # Secure root and create app user
    mariadb -u root <<EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${DB_ROOT_PASSWORD}');
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # # Run init SQL if present
    # for f in /docker-entrypoint-initdb.d/*.sql; do
    #     [ -f "$f" ] && envsubst '${MARIADB_DATABASE}' < "$f"| mariadb -u root -p"${DB_ROOT_PASSWORD}"
    # done

    # Stop the temporary instance
    kill $MYSQL_PID
    wait $MYSQL_PID
fi

# Hand off to mysqld as the main process
# exec mysqld --user=mysql
exec mysqld --user=mysql
