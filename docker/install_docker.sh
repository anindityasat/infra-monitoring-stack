#!/bin/bash
set -e

echo "== Checking Docker =="

if command -v docker &> /dev/null; then
  echo "Docker sudah terinstall."
  docker --version
else
  echo "Docker belum ada. Installing..."

  sudo apt update
  sudo apt install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update

  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Docker installed."
fi

echo "== Enable & Start Docker =="
sudo systemctl enable docker
sudo systemctl start docker

echo "== Add current user to docker group =="
sudo usermod -aG docker $USER

echo ""
echo "=== DONE ==="
echo "Logout & login ulang supaya docker bisa jalan tanpa sudo."
echo "Test: docker run hello-world"