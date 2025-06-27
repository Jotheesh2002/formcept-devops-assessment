

## 📊 Monitoring Stack for OpenSearch

### Purpose

Comprehensive monitoring stack for OpenSearch cluster health, performance, and alerting

### 🔹 Docker Compose Setup (`monitoring-stack.yml`)

```yaml
version: '3.8'

services:
  # Prometheus for metrics collection
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./config/alert_rules.yml:/etc/prometheus/alert_rules.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    networks:
      - monitoring
    restart: unless-stopped

  # Grafana for visualization
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
      - ./config/grafana/provisioning:/etc/grafana/provisioning
      - ./config/grafana/dashboards:/var/lib/grafana/dashboards
    networks:
      - monitoring
    restart: unless-stopped

  # OpenSearch Exporter
  opensearch-exporter:
    image: prometheuscommunity/elasticsearch-exporter:latest
    container_name: opensearch-exporter
    ports:
      - "9114:9114"
    environment:
      - ES_URI=https://admin:MyStrongPassword123!@opensearch-node1:9200
      - ES_ALL=true
      - ES_INDICES=true
      - ES_INDICES_SETTINGS=true
      - ES_SHARDS=true
      - ES_SNAPSHOTS=true
      - ES_TIMEOUT=30s
      - ES_SSL_SKIP_VERIFY=true
    networks:
      - monitoring
      - opensearch-net
    restart: unless-stopped
    depends_on:
      - prometheus

  # Node Exporter for system metrics
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
      - /etc/hostname:/etc/nodename
    command:
      - '--path.sysfs=/host/sys'
      - '--path.procfs=/host/proc'
      - '--collector.textfile.directory=/etc/node-exporter/'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
      - '--no-collector.ipvs'
    networks:
      - monitoring
    restart: unless-stopped

  # cAdvisor for container metrics
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - /dev/kmsg
    networks:
      - monitoring
    restart: unless-stopped

  # AlertManager for alerting
  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./config/alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager-data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
      - '--web.external-url=http://localhost:9093'
    networks:
      - monitoring
    restart: unless-stopped

volumes:
  prometheus-data:
  grafana-data:
  alertmanager-data:

networks:
  monitoring:
    driver: bridge
  opensearch-net:
    external: true
```

### 🔧 Configuration Files

#### Prometheus (`config/prometheus.yml`)

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # OpenSearch metrics
  - job_name: 'opensearch'
    static_configs:
      - targets: ['opensearch-exporter:9114']
    scrape_interval: 30s

  # Node metrics
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  # Container metrics
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # Prometheus self-monitoring
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Direct OpenSearch monitoring
  - job_name: 'opensearch-direct'
    scheme: https
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: admin
      password: MyStrongPassword123!
    static_configs:
      - targets: ['opensearch-node1:9200', 'opensearch-node2:9200', 'opensearch-node3:9200']
    metrics_path: /_prometheus/metrics
```

#### Alert Rules (`config/alert_rules.yml`)

```yaml
groups:
  - name: opensearch_alerts
    rules:
      - alert: OpenSearchClusterDown
        expr: up{job="opensearch"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "OpenSearch cluster is down"
          description: "OpenSearch exporter has been down for more than 1 minute"

      - alert: OpenSearchClusterRed
        expr: elasticsearch_cluster_health_status{color="red"} == 1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "OpenSearch cluster status is RED"
          description: "Cluster {{ $labels.cluster }} status is RED"

      - alert: OpenSearchClusterYellow
        expr: elasticsearch_cluster_health_status{color="yellow"} == 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "OpenSearch cluster status is YELLOW"
          description: "Cluster {{ $labels.cluster }} status is YELLOW"

      - alert: OpenSearchHighMemoryUsage
        expr: (elasticsearch_jvm_memory_used_bytes / elasticsearch_jvm_memory_max_bytes) * 100 > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High JVM memory usage on {{ $labels.name }}"
          description: "JVM memory usage is above 90% on node {{ $labels.name }}"

      - alert: OpenSearchHighDiskUsage
        expr: (elasticsearch_filesystem_data_used_bytes / elasticsearch_filesystem_data_size_bytes) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High disk usage on {{ $labels.name }}"
          description: "Disk usage is above 85% on node {{ $labels.name }}"

      - alert: OpenSearchNodeDown
        expr: elasticsearch_cluster_health_number_of_nodes < 3
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "OpenSearch node is down"
          description: "One or more OpenSearch nodes are down. Current nodes: {{ $value }}"

  - name: system_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% on {{ $labels.instance }}"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90% on {{ $labels.instance }}"
```

#### AlertManager (`config/alertmanager.yml`)

```yaml
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    email_configs:
      - to: 'admin@example.com'
        subject: 'OpenSearch Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts'
        title: 'OpenSearch Alert'
        text: |
          {{ range .Alerts }}
          {{ .Annotations.summary }}
          {{ .Annotations.description }}
          {{ end }}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
```

### 📈 Grafana Dashboard Configuration

#### Datasource Provisioning (`config/grafana/provisioning/datasources/prometheus.yml`)

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

#### Dashboard Provisioning (`config/grafana/provisioning/dashboards/dashboard.yml`)

```yaml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
```

### 🧪 Custom Metrics Collection

#### Exporter Script (`scripts/custom-metrics.py`)

```python
#!/usr/bin/env python3
import requests
import time
from prometheus_client import start_http_server, Gauge, Counter
import json

# Define metrics
OPENSEARCH_CUSTOM_METRIC = Gauge('opensearch_custom_indexing_rate', 'Custom indexing rate')
OPENSEARCH_QUERY_TIME = Gauge('opensearch_avg_query_time', 'Average query time')

def collect_metrics():
    try:
        # Collect custom metrics from OpenSearch
        response = requests.get(
            'https://localhost:9200/_stats',
            auth=('admin', 'MyStrongPassword123!'),
            verify=False
        )
        data = response.json()
        
        # Extract indexing rate
        indexing_rate = data['_all']['total']['indexing']['index_total']
        OPENSEARCH_CUSTOM_METRIC.set(indexing_rate)
        
        # Extract query performance
        query_time = data['_all']['total']['search']['query_time_in_millis']
        OPENSEARCH_QUERY_TIME.set(query_time)
        
    except Exception as e:
        print(f"Error collecting metrics: {e}")

if __name__ == '__main__':
    start_http_server(8001)
    while True:
        collect_metrics()
        time.sleep(30)
```

### 🚀 Deployment Commands

```bash
# Create config directories
mkdir -p config/grafana/provisioning/{datasources,dashboards}
mkdir -p config/grafana/dashboards

# Start monitoring services
docker-compose -f monitoring-stack.yml up -d

# Check services
docker-compose -f monitoring-stack.yml ps

# View logs
docker-compose -f monitoring-stack.yml logs -f grafana
```

#### Import Grafana Dashboards

```bash
curl -o config/grafana/dashboards/opensearch-dashboard.json \
  https://raw.githubusercontent.com/opensearch-project/dashboards-observability/main/grafana/opensearch-cluster-dashboard.json

docker-compose -f monitoring-stack.yml restart grafana
```

### 🌐 Monitoring Endpoints

* Prometheus: [http://localhost:9090](http://localhost:9090)
* Grafana: [http://localhost:3000](http://localhost:3000) (admin/admin123)
* AlertManager: [http://localhost:9093](http://localhost:9093)
* OpenSearch Exporter: [http://localhost:9114/metrics](http://localhost:9114/metrics)
* Node Exporter: [http://localhost:9100/metrics](http://localhost:9100/metrics)
* cAdvisor: [http://localhost:8080](http://localhost:8080)

### 📌 Key Metrics to Monitor

```bash
# Cluster health
curl http://localhost:9114/metrics | grep elasticsearch_cluster_health

# Node metrics
curl http://localhost:9114/metrics | grep elasticsearch_node

# Index metrics
curl http://localhost:9114/metrics | grep elasticsearch_indices

# JVM metrics
curl http://localhost:9114/metrics | grep elasticsearch_jvm
```

### ⚙️ Performance Tuning

#### Optimize Collection Intervals

```yaml
global:
  scrape_interval: 30s
  evaluation_interval: 30s
```

#### Set Resource Limits

```yaml
services:
  prometheus:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
```

✅ Your comprehensive monitoring stack is now ready to track OpenSearch cluster health, performance, and system metrics with alerting capabilities!

