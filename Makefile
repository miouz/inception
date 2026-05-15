NAME := inception

# ============================================================================ #
#                               COMPILOR & FLAGS                                  #
# ============================================================================ #

MAKE_CMD ?= $(MAKE)
# CXX := c++
# CXXFLAGS := -Wall -Wextra -Werror
# CXXFLAGS += -std=c++98
# DEBUG_FLAGS := -DDEBUG -O0

# ============================================================================ #
#                                DIRECTORIES                                   #
# ============================================================================ #

SRC_DIR := srcs
SECRET_DIR := secrets

# ============================================================================ #
#                                  SOURCES                                     #
# ============================================================================ #


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
all: $(NAME)
	@printf "$(GREEN)$(BOLD)✓ Build complete!\n$(RESET)"

#Link the final executable
$(NAME):
	@printf "$(CYAN)Linking $(NAME)...\n$(RESET)"
	@$(CXX) $(CXXFLAGS) main.cpp $(OBJS) -o $(NAME)
	@printf "$(GREEN)$(BOLD)✓ $(NAME) created successfully!🥳🥳🥳\n$(RESET)"

# ============================================================================ #
#                                 🍻CLEANNING                                    #
# ============================================================================ #

clean:
	@rm -rf $(OBJ_DIR)
	@printf '🧹$(GREEN)Cleaning .o files... m(｡≧ｴ≦｡)m$(RESET)🧹🧹\n'

fclean: clean
	@rm -f $(NAME) $(TEST_DIR)/$(TEST_NAME)
	# rm -f $(NAME_BONUS)
	@printf '🧹🧹$(GREEN)Nothing left...ლ(◉◞౪◟◉ )ლ$(RESET)🧹🧹\n'

re: fclean $(NAME)

# ============================================================================ #
#                              MAKEFILE SETTING                                #
# ============================================================================ #

#not print command
.SILENT:

#Delete target files if command fails
.DELETE_ON_ERROR:

.PHONY: all clean fclean re bonus
