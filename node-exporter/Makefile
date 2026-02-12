# Node Exporter version
VERSION ?= 1.7.0
BIN_DIR ?= /usr/local/bin
SERVICE_FILE ?= /etc/systemd/system/node-exporter.service

.PHONY: install start stop restart status update

install:
	@echo "Downloading Node Exporter v$(VERSION)..."
	wget https://github.com/prometheus/node_exporter/releases/download/v$(VERSION)/node_exporter-$(VERSION).linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
	tar xvf /tmp/node_exporter.tar.gz -C /tmp
	sudo mv /tmp/node_exporter-$(VERSION).linux-amd64/node_exporter $(BIN_DIR)/
	sudo useradd -rs /bin/false node_exporter || true

	@echo "Creating systemd service..."
	sudo tee $(SERVICE_FILE) > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=$(BIN_DIR)/node_exporter --collector.systemd
Restart=always

[Install]
WantedBy=multi-user.target
EOF

	sudo systemctl daemon-reload
	sudo systemctl enable node-exporter
	@echo "Node Exporter installed and enabled. Run 'make start' to start service."

start:
	sudo systemctl start node-exporter

stop:
	sudo systemctl stop node-exporter

restart:
	sudo systemctl restart node-exporter

status:
	sudo systemctl status node-exporter

update:
	$(MAKE) stop
	$(MAKE) install
	$(MAKE) start
