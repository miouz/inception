# User Documentation — Inception

This document explains how to operate the Inception infrastructure as an end user or administrator. No Docker expertise is required.

---

## What services are provided

The stack runs three services:

| Service | Role | Port |
|---|---|---|
| **NGINX** | Reverse proxy / TLS termination | 443 (HTTPS) |
| **WordPress + PHP-FPM** | Website and CMS | Internal only (port 9000) |
| **MariaDB** | Database | Internal only (port 3306) |

NGINX is the only service exposed to the outside world. All traffic enters through port 443 using HTTPS (TLS 1.2 or 1.3). WordPress and MariaDB are only reachable from within the Docker network — never directly from the host or the internet.

---

## Starting and stopping the project

All commands are run from the root of the repository (where the `Makefile` is located).

**Start the stack:**

```bash
make
```

This builds the images if needed and starts all three containers in the background. On first run it also generates the secret files automatically.

**Stop the stack (keeps your data):**

```bash
make down
```

This stops and removes the containers but leaves the volumes intact. Your WordPress content and database are preserved.

**Full reset (destroys all data):**

```bash
make clean
```

This stops containers and deletes the named volumes. Use this only if you want to start from a completely blank state.


```bash
make fclean
```

This stops containers, deletes the named volumes and remove the data directory on host machine. Use this only if you want to remove the host data dir as well.

---

## Accessing the website and admin panel

Make sure your `/etc/hosts` file contains the following line (replace `<login>` with your 42 login):

```
127.0.0.1   <login>.42.fr
```

**WordPress website:**

```
https://<login>.42.fr
```

Your browser will display a certificate warning because the TLS certificate is self-signed. This is expected — click "Advanced" and accept the exception.

**WordPress admin panel:**

```
https://<login>.42.fr/wp-admin
```

Log in with the WordPress admin credentials (see the section below on managing credentials).

---

## Locating and managing credentials

Credentials are stored in two places: secret files and the `.env` file.

### Secret files

Located in the `secrets/` directory at the root of the repository. These files are **not committed to Git**.

| File | Contains |
|---|---|
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/db_password.txt` | MariaDB WordPress user password |
| `secrets/wp_admin_password.txt` | WordPress admin password |
| `secrets/wp_user_password.txt` | WordPress user password |
| `secrets/credentials.txt` | WordPress admin username and password |

To read a secret:

```bash
cat secrets/credentials.txt
```

### Environment file

Located at `srcs/.env`. Contains non-sensitive configuration:

```bash
cat srcs/.env
```

Key variables:

| Variable | Description |
|---|---|
| `DOMAIN_NAME` | Your domain (e.g. `wil.42.fr`) |
| `MARIADB_DATABASE` | WordPress database name |
| `VOLUME_DIR` | The persistent data directory on host machine (/home/login/data) |
| `WP_TITLE` | WordPress title|
| `WP_ADMIN_USER` | WordPress admin user name |
| `WP_ADMIN_EMAIL` | WordPress admin user's email |
| `WP_USER` | WordPress  user name |
| `WP_USER_EMAIL` | WordPress user's email |
| `MARIADB_USER` | WordPress's mariadb user name |

### Regenerating secrets

If you need fresh passwords, delete the relevant files and run `make`:

```bash
rm *.txt
make clean   # removes old volumes so the new passwords take effect
make
```

---

## Checking that services are running correctly

**View running containers:**

```bash
# or directly:
docker compose -f srcs/docker-compose.yml ps
```

All three services (`nginx`, `wordpress`, `mariadb`) should show status `Up` or `running`.

**Follow live logs:**

```bash
make logs
# or for a specific service:
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

**Quick connectivity test:**

```bash
# Test that HTTPS is responding
curl -k https://<login>.42.fr
```

A response containing WordPress HTML means the full stack is working correctly.

Or open browser and go to https://<login>.42.fr


**Check that data persists:**

The named volumes are stored at:

```
/home/<login>/data/mariadb/   ← MariaDB database files
/home/<login>/data/wordpress/ ← WordPress website files
```

These directories survive container restarts and `make down`. They are only removed by `make fclean`.
