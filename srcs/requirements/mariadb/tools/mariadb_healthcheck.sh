#! /bin/bash
set -e

DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

exec mariadb -uroot -p"${DB_ROOT_PASSWORD}" -e "SELECT 1;" >/dev/null
