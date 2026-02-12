# ===============================
# Observability Stack Makefile
# ===============================

COMPOSE=docker compose
PROJECT_NAME=observability
ENV_FILE=.env

.PHONY: help install up down restart logs ps clean upgrade backup restore

help:
	@echo "Available commands:"
	@echo "  make install     -> Install docker & compose (Linux)"
	@echo "  make up          -> Start stack"
	@echo "  make down        -> Stop stack"
	@echo "  make restart     -> Restart stack"
	@echo "  make logs        -> Tail logs"
	@echo "  make ps          -> Show running services"
	@echo "  make clean       -> Stop and remove volumes (WARNING: delete data)"
	@echo "  make upgrade     -> Pull latest images & recreate"
	@echo "  make backup      -> Backup volumes"
	@echo "  make restore     -> Restore volumes (manual file required)"

install:
	@echo "Installing Docker..."
	curl -fsSL https://get.docker.com | sh
	@echo "Installing Docker Compose Plugin..."
	mkdir -p /usr/local/lib/docker/cli-plugins
	curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
		-o /usr/local/lib/docker/cli-plugins/docker-compose
	chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
	systemctl enable docker
	systemctl start docker
	@echo "Docker installed."

up:
	$(COMPOSE) --env-file $(ENV_FILE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) down
	$(COMPOSE) --env-file $(ENV_FILE) up -d

logs:
	$(COMPOSE) logs -f --tail=200

ps:
	$(COMPOSE) ps

upgrade:
	$(COMPOSE) pull
	$(COMPOSE) up -d

clean:
	$(COMPOSE) down -v
	docker volume prune -f

backup:
	@echo "Creating backup directory..."
	mkdir -p backup
	docker run --rm \
		-v grafana_data:/volume \
		-v $(PWD)/backup:/backup \
		alpine \
		tar czf /backup/grafana_data.tar.gz -C /volume .
	docker run --rm \
		-v prometheus_data:/volume \
		-v $(PWD)/backup:/backup \
		alpine \
		tar czf /backup/prometheus_data.tar.gz -C /volume .
	docker run --rm \
		-v loki_data:/volume \
		-v $(PWD)/backup:/backup \
		alpine \
		tar czf /backup/loki_data.tar.gz -C /volume .
	@echo "Backup completed in ./backup"

restore:
	@echo "Manual restore example:"
	@echo "docker run --rm -v grafana_data:/volume -v \$$PWD/backup:/backup alpine sh -c 'cd /volume && tar xzf /backup/grafana_data.tar.gz'"
