.PHONY: help backend frontend start-dev install clean dev-build dev-up dev-down dev-down-clean dev-setup dev-install dev-shell-backend dev-shell-frontend

# Variables
BACKEND_DIR = Backend
FRONTEND_DIR = Frontend

# Colors for terminal output
GREEN = \033[0;32m
NC = \033[0m # No Color

help: ## Show help information
	@echo "Available commands:"
	@echo "  make help              - Show this help message"
	@echo "  make install           - Install all dependencies (host)"
	@echo "  make backend           - Start backend server (host)"
	@echo "  make frontend          - Start frontend server (host)"
	@echo "  make start-dev         - Start both backend and frontend (host)"
	@echo "  make clean             - Clean temporary files (host)"
	@echo ""
	@echo "  Docker dev commands:"
	@echo "  make dev-build         - Build docker dev images"
	@echo "  make dev-up            - Start docker dev environment"
	@echo "  make dev-down          - Stop docker dev environment"
	@echo "  make dev-down-clean    - Stop containers + remove volumes (fresh start)"
	@echo "  make dev-setup         - Full setup: build, create DB, run migrations"
	@echo "  make dev-install       - Install/update dependencies inside containers"
	@echo "  make dev-shell-backend - Open shell in backend container"
	@echo "  make dev-shell-frontend- Open shell in frontend container"

install: ## Install dependencies
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	@cd $(BACKEND_DIR) && bundle install
	@echo "$(GREEN)Installing frontend dependencies...$(NC)"
	@cd $(FRONTEND_DIR) && npm install

backend: ## Start backend server
	@echo "$(GREEN)Starting backend server...$(NC)"
	@cd $(BACKEND_DIR) && bin/rails s

frontend: ## Start frontend server
	@echo "$(GREEN)Starting frontend server...$(NC)"
	@cd $(FRONTEND_DIR) && npm run dev

start-dev: ## Start both servers
	@echo "$(GREEN)Starting development environment...$(NC)"
	@make backend & make frontend

clean: ## Clean temporary files
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	@cd $(BACKEND_DIR) && rm -rf tmp/cache
	@cd $(FRONTEND_DIR) && rm -rf .next
	@echo "$(GREEN)Cleanup completed$(NC)"

# ==========================================
# Docker dev commands
# ==========================================

dev-build: ## Build docker dev images
	@echo "$(GREEN)Building dev docker images...$(NC)"
	docker compose build

dev-up: ## Start docker dev environment
	@echo "$(GREEN)Starting dev environment...$(NC)"
	docker compose up -d

dev-down: ## Stop docker dev environment
	@echo "$(GREEN)Stopping dev environment...$(NC)"
	docker compose down

dev-down-clean: ## Stop containers and remove volumes (resets DB/node_modules)
	@echo "$(GREEN)Stopping containers and removing volumes...$(NC)"
	docker compose down -v
	@echo "$(GREEN)Volumes removed. Next 'make dev-setup' will start fresh.$(NC)"

dev-setup: dev-build ## Full setup: build images, create DB, run migrations, start all services
	@echo "$(GREEN)Setting up database...$(NC)"
	docker compose up -d db
	@echo "$(GREEN)Waiting for database to be ready...$(NC)"
	sleep 3
	docker compose run --rm backend bin/rails db:create db:migrate
	@echo "$(GREEN)Starting all services...$(NC)"
	docker compose up -d
	@echo "$(GREEN)All services running. Use 'make dev-shell-backend' or 'make dev-shell-frontend' to enter containers.$(NC)"

dev-install: ## Install/update dependencies inside containers
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	docker compose exec backend bundle install
	@echo "$(GREEN)Installing frontend dependencies...$(NC)"
	docker compose exec frontend npm install --legacy-peer-deps

dev-shell-backend: ## Open shell in backend container
	docker compose exec backend bash

dev-shell-frontend: ## Open shell in frontend container
	docker compose exec frontend sh
