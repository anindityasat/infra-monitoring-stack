.PHONY: help up down up-dev up-staging up-prod down-all logs logs-otel logs-prometheus logs-loki logs-tempo logs-grafana status health-check build rebuild clean clean-volumes init test-connectivity validate-config

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# Default environment (development)
ENV ?= development

# Default target
.DEFAULT_GOAL := help

# ===========================
# HELP
# ===========================
help:
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Monitoring Stack - Makefile Commands                    ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Core Commands:$(NC)"
	@echo "  make up                - Start stack (default: development environment)"
	@echo "  make up ENV=staging    - Start in staging environment"
	@echo "  make up ENV=production - Start in production environment"
	@echo "  make up-dev            - Start in development (shorthand)"
	@echo "  make up-staging        - Start in staging (shorthand)"
	@echo "  make up-prod           - Start in production (shorthand)"
	@echo "  make down              - Stop stack (keep volumes)"
	@echo "  make down-all          - Stop and remove everything (including volumes)"
	@echo ""
	@echo "$(GREEN)Logs & Monitoring:$(NC)"
	@echo "  make logs          - View all service logs (follow mode)"
	@echo "  make logs-otel     - View OpenTelemetry Collector logs"
	@echo "  make logs-prometheus - View Prometheus logs"
	@echo "  make logs-loki     - View Loki logs"
	@echo "  make logs-tempo    - View Tempo logs"
	@echo "  make logs-grafana  - View Grafana logs"
	@echo "  make status        - Show status of all services"
	@echo "  make health-check  - Perform health check on all services"
	@echo ""
	@echo "$(GREEN)Configuration & Validation:$(NC)"
	@echo "  make init          - Initialize environment files and directories"
	@echo "  make validate-config - Validate docker-compose configuration"
	@echo "  make test-connectivity - Test connectivity between services"
	@echo ""
	@echo "$(GREEN)Build & Cleanup:$(NC)"
	@echo "  make build         - Build Docker images"
	@echo "  make rebuild       - Rebuild Docker images (no cache)"
	@echo "  make clean         - Clean up containers (keep volumes)"
	@echo "  make clean-volumes - Remove all volumes (WARNING: DATA LOSS)"
	@echo ""

# ===========================
# STARTUP COMMANDS
# ===========================

## Generic start command (ENV=development|staging|production, default: development)
up:
	@ENV_FILE=.env.$${ENV:-development}; \
	if [ ! -f "$$ENV_FILE" ]; then \
		echo "$(RED)Error: $$ENV_FILE not found$(NC)"; \
		exit 1; \
	fi; \
	if [ "$${ENV:-development}" = "production" ]; then \
		echo "$(YELLOW)⚠️  Starting monitoring stack in PRODUCTION environment$(NC)"; \
		echo "$(RED)Make sure you have configured production secrets in $$ENV_FILE$(NC)"; \
		read -p "Continue? [y/N] " -n 1 -r; \
		echo; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			docker-compose --env-file $$ENV_FILE up -d; \
			echo "$(GREEN)✓ Production environment started$(NC)"; \
			sleep 5 && make status; \
		else \
			echo "$(YELLOW)Cancelled$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)Starting monitoring stack in $${ENV:-development} environment...$(NC)"; \
		docker-compose --env-file $$ENV_FILE up -d; \
		echo "$(GREEN)✓ $${ENV:-development} environment started$(NC)"; \
		echo "$(BLUE)Access points:$(NC)"; \
		echo "  Grafana:        http://localhost:3000"; \
		echo "  Prometheus:     http://localhost:9090"; \
		echo "  Loki:           http://localhost:3100"; \
		echo "  Tempo:          http://localhost:3200"; \
		echo "  OTLP gRPC:      localhost:4317"; \
		echo "  OTLP HTTP:      http://localhost:4318"; \
		echo ""; \
		sleep 5 && make status; \
	fi

## Start in development environment
up-dev:
	@echo "$(YELLOW)Starting monitoring stack in DEVELOPMENT environment...$(NC)"
	@docker-compose --env-file .env.development up -d
	@echo "$(GREEN)✓ Development environment started$(NC)"
	@echo "$(BLUE)Access points:$(NC)"
	@echo "  Grafana:        http://localhost:3000"
	@echo "  Prometheus:     http://localhost:9090"
	@echo "  Loki:           http://localhost:3100"
	@echo "  Tempo:          http://localhost:3200"
	@echo "  OTLP gRPC:      localhost:4317"
	@echo "  OTLP HTTP:      http://localhost:4318"
	@echo ""
	@sleep 5 && make status

## Start in staging environment
up-staging:
	@echo "$(YELLOW)Starting monitoring stack in STAGING environment...$(NC)"
	@docker-compose --env-file .env.staging up -d
	@echo "$(GREEN)✓ Staging environment started$(NC)"
	@sleep 5 && make status

## Start in production environment
up-prod:
	@echo "$(YELLOW)⚠️  Starting monitoring stack in PRODUCTION environment$(NC)"
	@echo "$(RED)Make sure you have configured production secrets in .env.production$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose --env-file .env.production up -d; \
		echo "$(GREEN)✓ Production environment started$(NC)"; \
		sleep 5 && make status; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# ===========================
# SHUTDOWN COMMANDS
# ===========================

## Generic stop command
down:
	@echo "$(YELLOW)Stopping monitoring stack...$(NC)"
	@docker-compose down
	@echo "$(GREEN)✓ Stack stopped (volumes preserved)$(NC)"
	@echo "$(BLUE)Tip: Use 'make down-all' to remove volumes too$(NC)"

## Remove everything including volumes (DATA LOSS!)
down-all:
	@echo "$(RED)⚠️  WARNING: This will remove all data!$(NC)"
	@read -p "Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker-compose down -v; \
		echo "$(GREEN)✓ All containers and volumes removed$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# ===========================
# LOGS & MONITORING
# ===========================

## View all logs (follow mode)
logs:
	@docker-compose logs -f

## View OpenTelemetry Collector logs
logs-otel:
	@docker-compose logs -f otel-collector

## View Prometheus logs
logs-prometheus:
	@docker-compose logs -f prometheus

## View Loki logs
logs-loki:
	@docker-compose logs -f loki

## View Tempo logs
logs-tempo:
	@docker-compose logs -f tempo

## View Grafana logs
logs-grafana:
	@docker-compose logs -f grafana

## Show status of all services
status:
	@echo "$(BLUE)Service Status:$(NC)"
	@docker-compose ps

## Perform health checks on all services
health-check:
	@echo "$(BLUE)Performing health checks...$(NC)"
	@echo ""
	@echo "$(YELLOW)Checking Prometheus...$(NC)"
	@curl -s http://localhost:9090/-/healthy && echo " ✓" || echo " ✗"
	@echo ""
	@echo "$(YELLOW)Checking Loki...$(NC)"
	@curl -s http://localhost:3100/ready && echo " ✓" || echo " ✗"
	@echo ""
	@echo "$(YELLOW)Checking Tempo...$(NC)"
	@curl -s http://localhost:3200/status/build && echo " ✓" || echo " ✗"
	@echo ""
	@echo "$(YELLOW)Checking Grafana...$(NC)"
	@curl -s http://localhost:3000/api/health && echo " ✓" || echo " ✗"
	@echo ""
	@echo "$(YELLOW)Checking OTLP Collector Health...$(NC)"
	@curl -s http://localhost:13133 && echo " ✓" || echo " ✗"
	@echo ""

# ===========================
# BUILD COMMANDS
# ===========================

## Build Docker images
build:
	@echo "$(YELLOW)Building Docker images...$(NC)"
	@docker-compose build
	@echo "$(GREEN)✓ Build complete$(NC)"

## Rebuild Docker images (no cache)
rebuild:
	@echo "$(YELLOW)Rebuilding Docker images (no cache)...$(NC)"
	@docker-compose build --no-cache
	@echo "$(GREEN)✓ Rebuild complete$(NC)"

# ===========================
# CLEANUP COMMANDS
# ===========================

## Clean up containers (keep volumes)
clean:
	@echo "$(YELLOW)Cleaning up containers...$(NC)"
	@docker-compose down
	@docker system prune -f
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

## Remove all volumes (DATA LOSS WARNING!)
clean-volumes:
	@echo "$(RED)⚠️  WARNING: This will delete all data!$(NC)"
	@read -p "Type 'yes' to confirm deletion of all volumes: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker volume rm \
			infra-monitoring-stack_prometheus-storage \
			infra-monitoring-stack_loki-storage \
			infra-monitoring-stack_tempo-storage \
			infra-monitoring-stack_grafana-storage \
			2>/dev/null || true; \
		echo "$(GREEN)✓ All volumes removed$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# ===========================
# CONFIGURATION & VALIDATION
# ===========================

## Initialize environment and directories
init:
	@echo "$(YELLOW)Initializing monitoring stack...$(NC)"
	@echo ""
	@echo "$(BLUE)Checking environment files...$(NC)"
	@if [ ! -f .env.development ]; then echo "  ✗ .env.development missing"; else echo "  ✓ .env.development"; fi
	@if [ ! -f .env.staging ]; then echo "  ✗ .env.staging missing"; else echo "  ✓ .env.staging"; fi
	@if [ ! -f .env.production ]; then echo "  ✗ .env.production missing"; else echo "  ✓ .env.production"; fi
	@echo ""
	@echo "$(BLUE)Checking directories...$(NC)"
	@mkdir -p otel-collector prometheus loki tempo grafana/provisioning/datasources grafana/provisioning/dashboards dashboards alerts docs
	@echo "  ✓ All directories created"
	@echo ""
	@echo "$(BLUE)Checking configuration files...$(NC)"
	@if [ ! -f otel-collector/config.yaml ]; then echo "  ✗ otel-collector/config.yaml missing"; else echo "  ✓ otel-collector/config.yaml"; fi
	@if [ ! -f prometheus/prometheus.yml ]; then echo "  ✗ prometheus/prometheus.yml missing"; else echo "  ✓ prometheus/prometheus.yml"; fi
	@if [ ! -f loki/loki-config.yaml ]; then echo "  ✗ loki/loki-config.yaml missing"; else echo "  ✓ loki/loki-config.yaml"; fi
	@if [ ! -f tempo/tempo-config.yaml ]; then echo "  ✗ tempo/tempo-config.yaml missing"; else echo "  ✓ tempo/tempo-config.yaml"; fi
	@echo ""
	@echo "$(GREEN)✓ Initialization complete$(NC)"

## Validate docker-compose configuration
validate-config:
	@echo "$(YELLOW)Validating docker-compose configuration...$(NC)"
	@docker-compose config > /dev/null && echo "$(GREEN)✓ Configuration is valid$(NC)" || echo "$(RED)✗ Configuration is invalid$(NC)"

## Test connectivity between services
test-connectivity:
	@echo "$(YELLOW)Testing connectivity between services...$(NC)"
	@echo ""
	@docker-compose exec -T otel-collector curl -s http://prometheus:9090/-/healthy > /dev/null && echo "$(GREEN)✓ OTel → Prometheus$(NC)" || echo "$(RED)✗ OTel → Prometheus$(NC)"
	@docker-compose exec -T otel-collector curl -s http://loki:3100/ready > /dev/null && echo "$(GREEN)✓ OTel → Loki$(NC)" || echo "$(RED)✗ OTel → Loki$(NC)"
	@docker-compose exec -T otel-collector curl -s http://tempo:3200/status/build > /dev/null && echo "$(GREEN)✓ OTel → Tempo$(NC)" || echo "$(RED)✗ OTel → Tempo$(NC)"
	@docker-compose exec -T grafana curl -s http://prometheus:9090/-/healthy > /dev/null && echo "$(GREEN)✓ Grafana → Prometheus$(NC)" || echo "$(RED)✗ Grafana → Prometheus$(NC)"
	@docker-compose exec -T grafana curl -s http://loki:3100/ready > /dev/null && echo "$(GREEN)✓ Grafana → Loki$(NC)" || echo "$(RED)✗ Grafana → Loki$(NC)"
	@docker-compose exec -T grafana curl -s http://tempo:3200/status/build > /dev/null && echo "$(GREEN)✓ Grafana → Tempo$(NC)" || echo "$(RED)✗ Grafana → Tempo$(NC)"
	@echo ""
	@echo "$(GREEN)✓ Connectivity test complete$(NC)"

# ===========================
# DEVELOPMENT UTILITIES
# ===========================

## Install dev dependencies (if needed)
dev-install:
	@echo "$(YELLOW)Installing development dependencies...$(NC)"
	@which docker-compose > /dev/null || echo "$(RED)docker-compose not found$(NC)"
	@which docker > /dev/null || echo "$(RED)docker not found$(NC)"
	@which curl > /dev/null || echo "$(RED)curl not found$(NC)"

## Show environment configuration
show-env:
	@echo "$(BLUE)Current environment files:$(NC)"
	@ls -lh .env* 2>/dev/null || echo "No .env files found"

## Show service logs summary (last 50 lines)
logs-summary:
	@echo "$(BLUE)Recent logs (last 50 lines):$(NC)"
	@docker-compose logs --tail=50

## Restart a specific service
restart-service:
	@read -p "Enter service name to restart: " service; \
	docker-compose restart $$service; \
	echo "$(GREEN)✓ Service restarted$(NC)"

# ===========================
# GRAFANA UTILITIES
# ===========================

## Get Grafana admin password
show-grafana-password:
	@echo "$(BLUE)Grafana Admin Password:$(NC)"
	@grep GF_ADMIN_PASSWORD .env* 2>/dev/null | head -1 || echo "Not found in .env files"

## Reset Grafana admin password
reset-grafana-password:
	@echo "$(YELLOW)Resetting Grafana admin password...$(NC)"
	@docker-compose exec -T grafana grafana admin reset-admin-password newpassword
	@echo "$(GREEN)✓ Grafana admin password reset to: newpassword$(NC)"
	@echo "$(RED)⚠️  Remember to change this immediately!$(NC)"

# ===========================
# MONITORING & METRICS
# ===========================

## Get Prometheus targets status
prometheus-targets:
	@echo "$(BLUE)Prometheus Targets:$(NC)"
	@curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health: .health}' 2>/dev/null || echo "Failed to fetch targets"

## Get Grafana datasources
grafana-datasources:
	@echo "$(BLUE)Grafana Datasources:$(NC)"
	@curl -s -u admin:$$(grep GF_ADMIN_PASSWORD .env* | cut -d= -f2 | head -1) http://localhost:3000/api/datasources 2>/dev/null | jq '.[] | {name: .name, type: .type, url: .url}' || echo "Failed to fetch datasources"
