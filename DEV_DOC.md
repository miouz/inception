# Developer Documentation — Inception

This document describes how to set up, build, and operate the Inception project from a developer perspective.

---

## Project structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                        ← auto-generated, gitignored
│   ├── db_root_password.txt
│   ├── db_password.txt
│   ├── wp_user_password.txt
│   ├── wp_admin_password.txt
│   └── credentials.txt
└── srcs/
    ├── .env                        ← gitignored, copy from .env.example
    ├── .env.example                ← committed template
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf      ← HTTPS-only, TLS 1.2/1.3, proxy to wordpress:9000
        │   └── tools/
        │       └── generate_cert.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── wp_setup.sh   ← wp-cli setup, idempotent on wp-config.php
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── maraidb.cnf   ← bind-address=0.0.0.0, placed in mariadb.conf.d/
            └── tools/
                └── entrypoint.sh   ← bootstrap mysqld, create DB and users
                └── mariadb_healthcheck.sh
```

---

## Prerequisites

- Docker Engine (tested on 24+)
- Docker Compose plugin (`docker compose`, not `docker-compose`)
- GNU Make
- Add to `/etc/hosts`: `127.0.0.1 <login>.42.fr`

---

## Setting up the environment from scratch

### 1. Clone the repository

```bash
git clone <repo_url>
cd inception
```

### 2. Create the `.env` file

```bash
cp srcs/.env.example srcs/.env
# Edit srcs/.env and fill in your login and desired values
```

Minimum required variables:

```env
domain name of your site:
DOMAIN_NAME=

the persistent data directory to be mounted to a named volume:
VOLUME_DIR=/home/<login>/data

the name of maraidb's database
MARIADB_DATABASE=

the wordpress's mariadb user name:
MARIADB_USER=

the user name of wordpress:
WP_USER=
the email address of this user:
WP_USER_EMAIL=

the admin user name of wordpress:
WP_ADMIN_USER=
the email adress of admin user:
WP_ADMIN_EMAIL=

the title of wordpress:
WP_TITLE=
```

Do **not** put passwords in `.env`. They belong in `secrets/`.

### 3. Create the data directories

The named volumes store data on the host at:

```bash
mkdir -p /home/<login>/data/mariadb
mkdir -p /home/<login>/data/wordpress
```

The Makefile does this automatically, but you can create them manually if needed.

### 4. Generate secrets

The `secrets/` directory is gitignored. The Makefile generates missing files automatically on first `make`. To generate them manually:

```bash
make secrets
---

## Building and launching the project

```bash
# Full build and start (standard workflow)
make

# This runs:
#   docker compose -f srcs/docker-compose.yml build --no-cache
#   docker compose -f srcs/docker-compose.yml up -d
```

**Force a full rebuild with no cache:**

```bash
make re
# This runs: make clean && docker compose build --no-cache && docker compose up -d
```

---

## Key Makefile targets

| Target | Action |
|---|---|
| `make` | Generate missing secrets, build images, start containers |
| `make down` | Stop and remove containers, preserve volumes |
| `make clean` | `down --volumes --rmi all` — removes containers images **and** named volumes |
| `make re` | Full rebuild: clean + build --no-cache + up |
| `make logs` | Follow logs from all services |
| `make secrets` | Generate missing/empty secret files only |

---

## Managing containers and volumes

**Inspect a running container:**

```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

**Check MariaDB from inside the container:**

```bash
docker exec -it mariadb mariadb -u root -p
# password is in secrets/db_root_password
```

**List named volumes:**

```bash
docker volume ls

**Inspect a volume:**

```bash
docker volume inspect srcs_db_data
```

**Remove a specific volume manually:**

```bash
docker volume rm srcs_db_data
```

---

## How data persists

The two named volumes are mapped to host paths via `driver_opts` in `docker-compose.yml`:

```yaml
volumes:
  db:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/<login>/data/mariadb
  wp:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/<login>/data/wordpress
```

This means:

- `docker compose down` stops containers but host directories remain untouched
- `docker compose down -v` removes the volume metadata but **also** the volume directories are emptied
- The actual files live at `/home/<login>/data/` and survive reboots

---

## Configuration files explained

### NGINX (`srcs/requirements/nginx/conf/nginx.conf`)

- Listens on port 443 with TLS only (no port 80 block)
- TLS certificate generated at build time via `openssl` using `$DOMAIN_NAME`
- `ssl_protocols TLSv1.2 TLSv1.3` — enforced by the subject
- Proxies PHP requests to `wordpress:9000` via FastCGI

### PHP-FPM pool (`srcs/requirements/wordpress/tools/wp_setup.sh`)

- `listen = 0.0.0.0:9000` — TCP, not Unix socket, so NGINX can reach it across the network
- This is patched by `sed` in the wp_setup.sh 

### MariaDB (`srcs/requirements/mariadb/conf/mariadb.cnf`)

- Placed in `/etc/mysql/mariadb.conf.d/` (not `conf.d/`) so it loads **after** `50-server.cnf`
- Sets `bind-address = 0.0.0.0` to accept TCP connections from WordPress

---
