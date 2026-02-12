observability/
├── .env
├── docker-compose.yml
├── grafana/
│   ├── grafana.ini
│   └── provisioning/
├── loki/
│   ├── loki-config.yaml
├── prometheus/
│   ├── prometheus.yml
├── otel/
│   ├── otel-collector-config.yaml
└── scripts/
    └── install.sh

# Observability Production Stack

## Components
- Grafana (frontend)
- Prometheus (metrics)
- Loki (logs)
- OpenTelemetry Collector (OTLP ingestion)

## Usage
1. Edit `.env` sesuai kebutuhan
2. Siapkan config files di masing-masing folder
3. Start:
