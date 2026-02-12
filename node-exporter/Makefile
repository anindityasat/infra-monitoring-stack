VERSION ?= 1.10.2
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
	sudo /bin/bash -c "echo '[Unit]' > $(SERVICE_FILE)"
	sudo /bin/bash -c "echo 'Description=Node Exporter' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo 'After=network.target' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo '' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo '[Service]' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo 'User=node_exporter' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo 'ExecStart=$(BIN_DIR)/node_exporter --collector.systemd --web.listen-address=127.0.0.1:9100 --web.external-labels nodename=%H' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo 'Restart=always' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo '' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo '[Install]' >> $(SERVICE_FILE)"
	sudo /bin/bash -c "echo 'WantedBy=multi-user.target' >> $(SERVICE_FILE)"

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
