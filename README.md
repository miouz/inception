# 🐳 Inception

> **A containerized web infrastructure built from scratch with Docker Compose, NGINX, WordPress/PHP-FPM and MariaDB, with TLS, secrets management, health checks and persistent storage.**

*This project was created as part of the 42 curriculum by **Mi Zhou (mzhou / miouz)**.*

Inception is a **system administration and infrastructure project** focused on building a small production-style web stack using Docker.

Instead of relying on pre-built application images, each service is built from a **Debian Bookworm base image** and configured manually.

The infrastructure consists of three isolated services:

```text
                     HTTPS :443
                         │
                         ▼
                  ┌─────────────┐
                  │    NGINX    │
                  │ TLS Gateway │
                  └──────┬──────┘
                         │
                  FastCGI :9000
                         │
                         ▼
               ┌─────────────────┐
               │    WordPress    │
               │    PHP-FPM      │
               └────────┬────────┘
                        │
                  MariaDB :3306
                        │
                        ▼
                 ┌─────────────┐
                 │   MariaDB   │
                 │   Database  │
                 └─────────────┘
```

Only **NGINX is exposed to the host**. WordPress and MariaDB communicate exclusively through an internal Docker bridge network.

---

# ✨ Features

- 🐳 multi-container architecture with Docker Compose
- 🧱 custom Docker images built from Debian Bookworm
- 🌐 NGINX as the only public entry point
- 🔐 HTTPS with TLS 1.2 / TLS 1.3
- 📜 automatically generated self-signed TLS certificate
- 🐘 WordPress running through PHP-FPM
- 🗄️ MariaDB database service
- 🔑 password management through Docker secrets
- 🌱 non-sensitive configuration through `.env`
- 💾 persistent WordPress and database storage
- 🌉 isolated Docker bridge network
- ❤️ service health checks
- ⛓️ health-based service startup dependencies
- ⚙️ automatic database initialization
- 🚀 automatic WordPress installation with WP-CLI
- 🔄 restart policies
- 🛠️ Makefile-based infrastructure management

---

# 🏗️ Architecture

The infrastructure follows a simple rule:

> **Only the service that needs to be public should be public.**

```text
                         Internet / Host
                              │
                              │ HTTPS
                              │ :443
                              ▼
                    ┌───────────────────┐
                    │       NGINX       │
                    │                   │
                    │ TLS termination   │
                    │ Static files      │
                    │ FastCGI gateway   │
                    └─────────┬─────────┘
                              │
                     Docker Network
                              │
                              │ :9000
                              ▼
                    ┌───────────────────┐
                    │     WordPress     │
                    │                   │
                    │    PHP 8.2        │
                    │    PHP-FPM        │
                    │    WP-CLI         │
                    └─────────┬─────────┘
                              │
                              │ :3306
                              ▼
                    ┌───────────────────┐
                    │      MariaDB      │
                    │                   │
                    │ WordPress DB      │
                    │ Persistent data   │
                    └───────────────────┘
```

All three containers belong to the custom `inception` bridge network.

Docker's internal DNS allows services to communicate using their service names:

```text
nginx
   │
   └──────▶ wordpress:9000

wordpress
   │
   └──────▶ mariadb:3306
```

No hard-coded container IP addresses are required.

---

# 🐳 Container Design

Each service has its own Dockerfile and a single responsibility.

```text
requirements/
│
├── nginx/
│   ├── Dockerfile
│   ├── conf/
│   │   └── nginx.conf
│   └── tools/
│       └── generate_cert.sh
│
├── wordpress/
│   ├── Dockerfile
│   └── tools/
│       └── wp_setup.sh
│
└── mariadb/
    ├── Dockerfile
    ├── conf/
    │   └── mariadb.cnf
    └── tools/
        ├── entry-point.sh
        └── mariadb_healthcheck.sh
```

The services are not pulled as ready-made NGINX, WordPress or MariaDB images.

Instead, their dependencies are installed and configured inside custom images based on:

```dockerfile
FROM debian:bookworm
```

This made the project less about *using containers* and more about understanding **how the services inside those containers actually work**.

---

# 🌐 NGINX

NGINX is the only service exposed outside the Docker network.

```text
Host
 │
 │ :443
 ▼
NGINX
```

Its responsibilities include:

- accepting HTTPS connections;
- TLS termination;
- serving WordPress files;
- forwarding PHP requests to PHP-FPM;
- preventing direct exposure of backend services.

The container exposes:

```text
443 → HTTPS
```

There is no public MariaDB or PHP-FPM port.

---

# 🔐 TLS

The NGINX container generates a self-signed certificate during startup using OpenSSL.

The server configuration only enables:

```text
TLSv1.2
TLSv1.3
```

The resulting request flow is:

```text
Browser
   │
   │ HTTPS
   ▼
NGINX
   │
   │ FastCGI
   ▼
PHP-FPM
```

NGINX therefore acts as the **TLS boundary** for the infrastructure.

---

# 🐘 WordPress & PHP-FPM

WordPress runs in its own container with:

```text
PHP 8.2
PHP-FPM
WP-CLI
MariaDB client
```

PHP-FPM listens on:

```text
0.0.0.0:9000
```

inside the Docker network.

NGINX forwards PHP requests using:

```nginx
fastcgi_pass wordpress:9000;
```

This keeps the web server and application runtime in separate containers.

---

# 🚀 Automated WordPress Setup

The WordPress container contains a custom initialization script.

On startup it:

```text
Read Docker secrets
        │
        ▼
Wait for MariaDB
        │
        ▼
Check existing WordPress installation
        │
        ├── already configured ──▶ continue
        │
        ▼
Download WordPress
        │
        ▼
Generate wp-config.php
        │
        ▼
Install WordPress
        │
        ▼
Create admin account
        │
        ▼
Create regular user
        │
        ▼
Start PHP-FPM
```

WP-CLI is used to perform the installation automatically.

The initialization is designed around persistent storage: if `wp-config.php` already exists, WordPress is not installed again.

---

# 🗄️ MariaDB

MariaDB runs in a dedicated database container.

Its custom entry point initializes the database only when the persistent database directory has not already been initialized.

On the first launch:

```text
Empty /var/lib/mysql
        │
        ▼
Initialize MariaDB
        │
        ▼
Start temporary server
        │
        ▼
Configure root authentication
        │
        ▼
Remove anonymous users
        │
        ▼
Remove test database
        │
        ▼
Create WordPress database
        │
        ▼
Create WordPress DB user
        │
        ▼
Grant database privileges
        │
        ▼
Stop temporary server
        │
        ▼
Start MariaDB normally
```

On later launches, the initialization phase is skipped because the database already exists in persistent storage.

---

# ❤️ Health Checks & Startup Ordering

Starting containers in the correct order is not enough.

A container can be **running** while the application inside it is still initializing.

The stack therefore uses health checks.

```text
MariaDB
   │
   │ healthcheck
   ▼
healthy
   │
   ▼
WordPress starts
   │
   │ healthcheck :9000
   ▼
healthy
   │
   ▼
NGINX starts
```

WordPress declares:

```text
depends_on:
    mariadb:
        condition: service_healthy
```

and NGINX waits for WordPress to become healthy.

This makes service startup depend on **application readiness rather than only container creation order**.

---

# 🔑 Secrets Management

Sensitive credentials are kept outside the Docker images and Compose configuration.

The project uses secret files for:

```text
MariaDB root password
MariaDB WordPress-user password
WordPress admin password
WordPress user password
```

Inside a container they are accessed through:

```text
/run/secrets/
```

For example:

```bash
DB_PASSWORD="$(cat /run/secrets/db_password)"
```

The secret files are generated locally and excluded from Git.

---

# 🌱 Environment Configuration

Non-sensitive configuration is separated into `.env`.

Examples include:

```env
DOMAIN_NAME=mzhou.42.fr
VOLUME_DIR=/home/mzhou/data
MARIADB_DATABASE=inception_database
MARIADB_USER=maria
WP_TITLE=mzhou
```

This creates a separation between:

```text
.env
 │
 └── non-sensitive configuration

secrets/
 │
 └── passwords and credentials
```

An `.env.example` file documents the required configuration without committing private credentials.

---

# 💾 Persistent Storage

Containers are disposable.

Application data should not be.

The infrastructure therefore defines two persistent volumes:

```text
MariaDB
   │
   ▼
db volume
   │
   ▼
/home/mzhou/data/db


WordPress
   │
   ▼
wordpress volume
   │
   ▼
/home/mzhou/data/wordpress
```

The volumes preserve:

- MariaDB database files;
- WordPress installation files;
- uploaded content;
- application state.

Containers can therefore be destroyed and recreated without automatically destroying the application's data.

---

# 🌉 Network Isolation

All services belong to a custom bridge network:

```yaml
networks:
  inception:
    driver: bridge
```

Only NGINX publishes a host port:

```text
443:443
```

WordPress and MariaDB remain internal.

```text
                    HOST
                     │
                  :443 only
                     │
                     ▼
                  NGINX
                     │
         ┌───────────┴───────────┐
         │   inception network   │
         │                       │
         ▼                       ▼
     WordPress                MariaDB
       :9000                    :3306
```

This reduces the externally reachable surface of the stack.

---

# 🔄 Request Lifecycle

A request to the WordPress site travels through several infrastructure layers:

```text
Browser
   │
   │ HTTPS :443
   ▼
NGINX
   │
   ├── static file ───────────────▶ response
   │
   └── PHP request
          │
          │ FastCGI :9000
          ▼
      PHP-FPM
          │
          │ SQL :3306
          ▼
       MariaDB
          │
          ▼
      PHP-FPM
          │
          ▼
        NGINX
          │
          ▼
       Browser
```

Each service has a clear responsibility and communicates with the next service over the Docker network.

---

# ⚙️ Docker Compose Orchestration

Docker Compose defines the infrastructure declaratively.

It coordinates:

```text
images
containers
networks
volumes
secrets
environment variables
health checks
dependencies
restart policies
ports
```

This means the entire stack can be reproduced from configuration rather than manually configuring each service.

---

# 🛠️ Makefile Automation

A Makefile provides the main interface for operating the infrastructure.

## Build and start

```bash
make
```

The default workflow:

```text
Generate missing secrets
        │
        ▼
Create persistent directories
        │
        ▼
Build Docker images
        │
        ▼
Start Compose stack
```

## Stop

```bash
make down
```

Stops the containers while preserving persistent data.

## Logs

```bash
make logs
```

Follows logs from the Compose services.

## Clean

```bash
make clean
```

Removes containers, Compose volumes and images.

## Full cleanup

```bash
make fclean
```

Also removes the host data directory.

## Rebuild

```bash
make re
```

Performs a clean rebuild of the infrastructure.

---

# 🏗️ Project Structure

```text
inception/
│
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
│
├── secrets/                    # generated locally / gitignored
│
└── srcs/
    │
    ├── .env
    ├── .env.example
    ├── docker-compose.yml
    │
    └── requirements/
        │
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── generate_cert.sh
        │
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── wp_setup.sh
        │
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── mariadb.cnf
            └── tools/
                ├── entry-point.sh
                └── mariadb_healthcheck.sh
```

Additional documentation is provided through:

```text
USER_DOC.md    → operating the infrastructure
DEV_DOC.md     → implementation and development details
```

---

# 🧠 Engineering Challenges

### 🐳 Building Services Instead of Pulling Them

Rather than relying on ready-made NGINX, WordPress and MariaDB images, each environment had to be constructed and configured manually from Debian.

This required understanding what each service actually needs to start and communicate.

### ⛓️ Coordinating Service Readiness

Container startup order and application readiness are different problems.

Health checks and conditional dependencies were used so downstream services only start once their dependencies are actually usable.

### 💾 Separating Containers from Data

Containers should be replaceable without losing application state.

Persistent volumes separate the service lifecycle from the data lifecycle.

### 🔑 Handling Credentials

Passwords should not become Dockerfile layers, Compose values or committed environment variables.

Separating sensitive secrets from normal configuration reduces accidental credential exposure.

### 🌐 Connecting Independent Services

NGINX, PHP-FPM and MariaDB run in separate environments but still need reliable communication.

Docker networking and internal DNS provide this without exposing backend ports publicly.

### 🚀 Idempotent Initialization

Container startup scripts must distinguish between:

```text
first startup
```

and:

```text
restart with existing persistent data
```

Both WordPress and MariaDB setup logic account for existing state to avoid reinstalling or reinitializing persistent services.

---

# 🎯 What I Learned

Inception moved beyond application code into the infrastructure required to run applications reliably.

### 🐳 Containers

- Docker images
- Dockerfiles
- container lifecycle
- entrypoints
- PID 1 behavior
- image layers
- service isolation

### ⚙️ Infrastructure

- Docker Compose
- service orchestration
- health checks
- dependency management
- persistent volumes
- bridge networking
- internal DNS

### 🌐 Web Infrastructure

- NGINX
- HTTPS
- TLS certificates
- FastCGI
- PHP-FPM
- WordPress
- MariaDB

### 🔐 Security

- secrets management
- network isolation
- limited port exposure
- configuration separation
- database users and privileges

The main lesson was that deploying an application is not just about starting processes.

A reliable infrastructure also needs to answer:

```text
How do services discover each other?

Which services are externally reachable?

When is a dependency actually ready?

Where does persistent data live?

How are credentials delivered safely?

What happens when a container restarts?

How can the entire environment be reproduced?
```

Those questions are the core of this project.

---

# 🤖 Use of AI

AI tools were used as a **technical learning and documentation aid** during this project.

In particular, Claude was used in a mentor-style workflow to:

- explain unfamiliar Docker and infrastructure concepts;
- discuss the reasoning behind configuration and architectural choices;
- help understand container networking, volumes, secrets and service initialization;
- clarify infrastructure behavior and debugging approaches;
- help structure and improve `README.md`, `DEV_DOC.md` and `USER_DOC.md`.

The Dockerfiles, Compose architecture, service configuration, shell scripts, debugging and technical decisions were implemented and worked through as part of the project.


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

---

# 👨‍💻 Author

**Mi Zhou (mzhou / miouz)**

*Inception — 42 School*
