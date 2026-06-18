NAME := Inception

# ============================================================================ #
#                               COMPILOR & FLAGS                                  #
# ============================================================================ #

MAKE_CMD ?= $(MAKE)

# ============================================================================ #
#                                DIRECTORIES                                   #
# ============================================================================ #

SRC_DIR := srcs
SECRET_DIR := secrets
DATA_DIR := /home/mzhou/data
DB_DIR := $(DATA_DIR)/db
WORDPRESS_DIR := $(DATA_DIR)/wordpress

# ============================================================================ #
#                                  SOURCES                                     #
# ============================================================================ #

COMPOSE_FILE := $(SRC_DIR)/docker-compose.yml
ENV_FILE := $(SRC_DIR)/.env


# ============================================================================ #
#                                   COLORS                                     #
# ============================================================================ #

#color variables
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
MAGENTA := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
RESET := \033[0m
BOLD := \033[1m

# ============================================================================ #
#                                  🫡RULES                                      #
# ============================================================================ #


#Default target
all: 
	@printf "$(CYAN)Building $(NAME)...\n$(RESET)"
	mkdir -p $(DATA_DIR) && \
	mkdir -p $(DB_DIR) && \
	mkdir -p $(WORDPRESS_DIR) && \
	docker compose -f $(COMPOSE_FILE) build --no-cache
	docker compose -f $(COMPOSE_FILE) up
	@printf "$(GREEN)$(BOLD)✓ $(NAME) created successfully!🥳🥳🥳\n$(RESET)"

#Follow logs
logs:
	@printf "$(CYAN)Showing logs...\n$(RESET)"
	docker compose -f $(COMPOSE_FILE) logs -f

#Stop containers
down:
	@printf "$(CYAN)Stopping $(NAME)...\n$(RESET)"
	docker compose -f $(COMPOSE_FILE) down
	@printf "$(GREEN)$(BOLD)✓ $(NAME) is down 🥳🥳🥳\n$(RESET)"

re: fclean all



# ============================================================================ #
#                                 🍻CLEANNING                                    #
# ============================================================================ #

#Stop and remove the volumes and images
clean: down
	@printf "🧹$(CYAN)Cleaning volumes and images..\n$(RESET)"
	docker compose -f $(COMPOSE_FILE) down --volumes --rmi all
	@printf "$(GREEN)$(BOLD)✓ Cleaned🧹🧹🧹\n$(RESET)"

#Fully reset (clean + remove DATA_DIR)
fclean: clean
	@printf "🧹$(CYAN)Removing persistent data..\n$(RESET)"
	rm -rf $(DATA_DIR)
	@printf "$(GREEN)$(BOLD)✓ $(DATA_DIR) is removed successfully!🧹🧹🧹🧹\n$(RESET)"


# ============================================================================ #
#                              MAKEFILE SETTING                                #
# ============================================================================ #

#not print command
.SILENT:

#Delete target files if command fails
.DELETE_ON_ERROR:

.PHONY: all clean fclean re bonus logs down
