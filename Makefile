.PHONY: help backend install clean lint lint-fix dev-build dev-up dev-down dev-down-clean dev-setup dev-install dev-lint dev-lint-fix dev-shell-backend

# Colors for terminal output
GREEN = \033[0;32m
NC = \033[0m # No Color

help: ## Show help information
	@echo "Available commands:"
	@echo "  make help              - Show this help message"
	@echo "  make install           - Install all dependencies (host)"
	@echo "  make backend           - Start backend server (host)"
	@echo "  make lint              - Run RuboCop linter (host)"
	@echo "  make lint-fix          - Run RuboCop auto-correct (host)"
	@echo "  make clean             - Clean temporary files (host)"
	@echo ""
	@echo "  Docker dev commands:"
	@echo "  make dev-build         - Build docker dev images"
	@echo "  make dev-up            - Start docker dev environment"
	@echo "  make dev-down          - Stop docker dev environment"
	@echo "  make dev-down-clean    - Stop containers + remove volumes (fresh start)"
	@echo "  make dev-setup         - Full setup: build, create DB, run migrations"
	@echo "  make dev-install       - Install/update dependencies inside containers"
	@echo "  make dev-lint          - Run RuboCop linter inside backend container"
	@echo "  make dev-lint-fix      - Run RuboCop auto-correct inside backend container"
	@echo "  make dev-shell-backend - Open shell in backend container"

install: ## Install dependencies
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	@bundle install

backend: ## Start backend server
	@echo "$(GREEN)Starting backend server...$(NC)"
	@bin/rails s

lint: ## Run RuboCop linter (host)
	@echo "$(GREEN)Running RuboCop...$(NC)"
	@bundle exec rubocop

lint-fix: ## Run RuboCop auto-correct (host)
	@echo "$(GREEN)Running RuboCop auto-correct...$(NC)"
	@bundle exec rubocop -A

clean: ## Clean temporary files
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	@rm -rf tmp/cache
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

dev-down-clean: ## Stop containers and remove volumes (resets DB volume)
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
	@echo "$(GREEN)All services running. Use 'make dev-shell-backend' to enter container.$(NC)"

dev-install: ## Install/update dependencies inside containers
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	docker compose exec backend bundle install

dev-lint: ## Run RuboCop linter inside backend container
	@echo "$(GREEN)Running RuboCop inside backend container...$(NC)"
	docker compose exec -T backend bundle exec rubocop

dev-lint-fix: ## Run RuboCop auto-correct inside backend container
	@echo "$(GREEN)Running RuboCop auto-correct inside backend container...$(NC)"
	docker compose exec -T backend bundle exec rubocop -A

dev-shell-backend: ## Open shell in backend container
	docker compose exec backend bash
