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

# ============================================================================ #
#                                  SOURCES                                     #
# ============================================================================ #

COMPOSE_FILE := $(SRC_DIR)/docker-compose.yml


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
	docker compose -f $(COMPOSE_FILE) up -d --build
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

#Stop and remove the volumes and images
clean: down
	@printf "🧹$(CYAN)Cleaning volumes and images..\n$(RESET)"
	docker compose -f $(COMPOSE_FILE) down --volumes --rmi all
	@printf "$(GREEN)$(BOLD)✓ Cleaned🧹🧹🧹\n$(RESET)"

#Fully reset (clean + remove DATA_DIR)
fclean: clean
	@printf "🧹$(CYAN)Removing persistent data..\n$(RESET)"
	rm -f $(DATA_DIR)
	@printf "$(GREEN)$(BOLD)✓ $(DATA_DIR) is removed successfully!🧹🧹🧹🧹\n$(RESET)"



# ============================================================================ #
#                                 🍻CLEANNING                                    #
# ============================================================================ #

# clean:
# 	@printf '🧹$(GREEN)Cleaning .o files... m(｡≧ｴ≦｡)m$(RESET)🧹🧹\n'
#
# fclean: clean
# 	@printf '🧹🧹$(GREEN)Nothing left...ლ(◉◞౪◟◉ )ლ$(RESET)🧹🧹\n'
#
# re: fclean $(NAME)

# ============================================================================ #
#                              MAKEFILE SETTING                                #
# ============================================================================ #

#not print command
.SILENT:

#Delete target files if command fails
.DELETE_ON_ERROR:

.PHONY: all clean fclean re bonus logs down
