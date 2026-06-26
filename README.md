*This project has been created as part of the 42 curriculum by mzhou

# Inception

## Description

Inception is a system administration project built around Docker. The goal is to set up a small but complete web infrastructure composed of three services — NGINX, WordPress + PHP-FPM, and MariaDB — each running in its own dedicated container, orchestrated via Docker Compose.

All images are built from scratch using Debian Bookworm as the base; no pre-built service images are pulled from Docker Hub. The project enforces strict security practices: passwords are managed via Docker secrets, non-sensitive configuration lives in a `.env` file, and no credentials are ever committed to the repository.

### Design choices

**Virtual Machines vs Docker**

A VM virtualizes an entire operating system including the kernel, which gives full isolation but at the cost of significant overhead (memory, boot time, disk). Docker containers share the host kernel and isolate only the process namespace and filesystem, making them far lighter. For this project, each service gets its own container — not because containers replace VMs, but because they are the right tool for packaging a single-purpose process with its dependencies.

**Secrets vs Environment Variables**

Environment variables are readable by any process in the container and can leak through `docker inspect`, logs, or child processes. Docker secrets are mounted as in-memory files under `/run/secrets/` and are only accessible to the container that explicitly declares them. Passwords (DB root password, DB user password, WordPress admin password) are stored as secrets. Non-sensitive config (domain name, database name, usernames) lives in `.env`.

**Docker Network vs Host Network**

`network: host` removes all network isolation — the container shares the host's network stack directly, which defeats the purpose of containerisation and creates security risks. This project uses a custom bridge network (`inception`) defined in `docker-compose.yml`. Containers communicate by service name (DNS resolution within the network), and only port 443 is exposed to the host via NGINX.

**Docker Volumes vs Bind Mounts**

Bind mounts tie a container to a specific host path and require the directory to exist before the container starts. Named volumes are managed by Docker, survive container recreation, and are portable. The subject explicitly requires named volumes for both the WordPress files and the MariaDB database. Their data is stored under `/home/mzhou/data` on the host machine via the `driver_opts` configuration in `docker-compose.yml`.

---

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Can be set up in a VM or any machine with sudo permission
- Add `mzhou.42.fr` pointing to `127.0.0.1` in `/etc/hosts` on the host machine

### Setup

```bash
# Clone the repository
git clone <repo_url>
cd inception

# The Makefile auto-generates secrets if missing and builds everything
make
```

The `make` target will:
1. Create `secrets/` files (random passwords) if they do not already exist
2. Run `docker compose build` to build all three images
3. Run `docker compose up -d` to start the stack

### Useful commands

```bash
make          # Build images and start the stack
make secrets  # Generate random passwords if they do not already exist
make down     # Stop and remove containers (preserves volumes)
make clean    # Stop containers, remove volumes and images
make fclean   # Stop containers, remove volumes and images, removes data directory (/home/mzhou/data)
make re       # Full rebuild from scratch without removing data directory
make logs     # Follow logs from all services
```

### Access

Once running, the WordPress site is available at:

```
https://mzhou.42.fr
```

The browser will warn about a self-signed certificate — this is expected. Accept the exception to proceed. The WordPress admin panel is at:

```
https://mzhou.42.fr/wp-admin
```

---

## Resources

### Documentation

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [WP-CLI documentation](https://wp-cli.org/)
- [Debian package search](https://packages.debian.org/)

### Key articles

- [PID 1 problem in containers](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [MariaDB authentication plugin](https://mariadb.com/kb/en/authentication-plugin-mysql_native_password/)

### AI usage

Claude was used as a technical mentor throughout this project in Socratic mode — asking guiding questions and explaining the *why* behind each decision rather than generating code directly. It was also used for helping generating README.md, DEV_DOC.md and USER_DOC.md
