#!/bin/bash
set -e

echo "==> Installing Docker ..."
curl -fsSL https://get.docker.com | sh

echo "==> Installing Docker Compose ..."
DOCKER_COMPOSE_VERSION=v2.22.1
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "==> Enable services ..."
systemctl enable docker
systemctl start docker

echo "Done."
