#!/bin/bash
set -e

echo "== Stop Docker service =="
sudo systemctl stop docker 2>/dev/null || true
sudo systemctl stop containerd 2>/dev/null || true

echo "== Disable Docker service =="
sudo systemctl disable docker 2>/dev/null || true

echo "== Remove Docker packages =="
sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
sudo apt purge -y docker-ce-rootless-extras 2>/dev/null || true
sudo apt autoremove -y
sudo apt autoclean

echo "== Remove Docker data =="
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker

echo "== Remove Docker repo & keyring =="
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg

echo "== Remove docker group (if exists) =="
if getent group docker > /dev/null; then
  sudo groupdel docker
fi

echo ""
echo "=== DOCKER CLEAN COMPLETE ==="
echo "System sudah bersih dari Docker Engine (official repo)."