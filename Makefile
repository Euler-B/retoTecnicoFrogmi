.PHONY: help backend frontend start-dev install clean

# Variables
BACKEND_DIR = Backend
FRONTEND_DIR = Frontend

# Colors for terminal output
GREEN = \033[0;32m
NC = \033[0m # No Color

help: ## Show help information
	@echo "Available commands:"
	@echo "  make help          - Show this help message"
	@echo "  make install       - Install all dependencies"
	@echo "  make backend       - Start backend server"
	@echo "  make frontend      - Start frontend server"
	@echo "  make start-dev     - Start both backend and frontend"
	@echo "  make clean         - Clean temporary files"

install: ## Install dependencies
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	@cd $(BACKEND_DIR) && bundle install
	@echo "$(GREEN)Installing frontend dependencies...$(NC)"
	@cd $(FRONTEND_DIR) && pnpm install

backend: ## Start backend server
	@echo "$(GREEN)Starting backend server...$(NC)"
	@cd $(BACKEND_DIR) && bin/rails s

frontend: ## Start frontend server
	@echo "$(GREEN)Starting frontend server...$(NC)"
	@cd $(FRONTEND_DIR) && pnpm dev

start-dev: ## Start both servers
	@echo "$(GREEN)Starting development environment...$(NC)"
	@make backend & make frontend

clean: ## Clean temporary files
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	@cd $(BACKEND_DIR) && rm -rf tmp/cache
	@cd $(FRONTEND_DIR) && rm -rf .next
	@echo "$(GREEN)Cleanup completed$(NC)"