VERSION ?= 1.10.2
BIN_DIR ?= /usr/local/bin
SERVICE_FILE ?= /etc/systemd/system/node-exporter.service

.PHONY: install start stop restart status update

install:
	wget https://github.com/prometheus/node_exporter/releases/download/v$(VERSION)/node_exporter-$(VERSION).linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
	tar -xzf /tmp/node_exporter.tar.gz -C /tmp
	sudo mv /tmp/node_exporter-$(VERSION).linux-amd64/node_exporter $(BIN_DIR)/
	sudo chmod +x $(BIN_DIR)/node_exporter
	sudo useradd -rs /bin/false node_exporter || true

	sudo bash -c "echo '[Unit]' > $(SERVICE_FILE)"
	sudo bash -c "echo 'Description=Node Exporter' >> $(SERVICE_FILE)"
	sudo bash -c "echo 'After=network.target' >> $(SERVICE_FILE)"
	sudo bash -c "echo '' >> $(SERVICE_FILE)"
	sudo bash -c "echo '[Service]' >> $(SERVICE_FILE)"
	sudo bash -c "echo 'User=node_exporter' >> $(SERVICE_FILE)"
	sudo bash -c "echo 'Group=node_exporter' >> $(SERVICE_FILE)"
	sudo bash -c "echo 'Type=simple' >> $(SERVICE_FILE)"
	sudo bash -c "echo 'ExecStart=$(BIN_DIR)/node_exporter --collector.systemd --web.listen-address=127.0.0.1:49100' >> $(SERVICE_FILE)"
	sudo bash -c "echo 'Restart=always' >> $(SERVICE_FILE)"
	sudo bash -c "echo '' >> $(SERVICE_FILE)"
	sudo bash -c "echo '[Install]' >> $(SERVICE_FILE)"
	sudo bash -c "echo 'WantedBy=multi-user.target' >> $(SERVICE_FILE)"

	sudo systemctl daemon-reload
	sudo systemctl enable node-exporter

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
