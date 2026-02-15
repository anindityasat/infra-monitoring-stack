VERSION ?= 1.10.2
BIN_DIR ?= /usr/local/bin
SERVICE_FILE ?= /etc/systemd/system/node-exporter.service

.PHONY: install start stop restart status update

install:
	@echo "Downloading Node Exporter v$(VERSION)..."
	wget https://github.com/prometheus/node_exporter/releases/download/v$(VERSION)/node_exporter-$(VERSION).linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
	tar -xzf /tmp/node_exporter.tar.gz -C /tmp
	sudo mv /tmp/node_exporter-$(VERSION).linux-amd64/node_exporter $(BIN_DIR)/
	sudo chmod +x $(BIN_DIR)/node_exporter
	sudo useradd -rs /bin/false node_exporter || true

	@echo "Creating systemd service..."
	sudo tee $(SERVICE_FILE) > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=$(BIN_DIR)/node_exporter \
  --collector.systemd \
  --web.listen-address=127.0.0.1:9100
Restart=always

[Install]
WantedBy=multi-user.target
EOF

	sudo systemctl daemon-reload
	sudo systemctl enable node-exporter
	@echo "Node Exporter installed and enabled."

start:
	sudo systemctl start node-exporter

stop:
	sudo systemctl stop node-exporter

restart:
	sudo systemctl daemon-reload
	sudo systemctl restart node-exporter

status:
	sudo systemctl status node-exporter

update:
	$(MAKE) stop
	$(MAKE) install
	$(MAKE) start
