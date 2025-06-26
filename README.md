<h1 align="center">🚀 FORMCEPT DevOps Internship Assessment</h1>
<h4 align="center">Comprehensive Containerization & Kubernetes Implementation by Jotheeshwaran V</h4>

<p align="center">
  <img src="https://img.shields.io/badge/DevOps-Docker%2C%20Kubernetes-blue" />
  <img src="https://img.shields.io/badge/Monitoring-Prometheus%20%26%20Grafana-yellow" />
  <img src="https://img.shields.io/badge/Cloud-Native-green" />
  <img src="https://img.shields.io/badge/License-Educational-lightgrey" />
</p>

---

## 📋 Overview

This repository showcases a full-stack DevOps solution covering containerization, orchestration, monitoring, and deployment using:

- **Docker & Docker Compose**
- **OpenSearch Cluster**
- **Prometheus & Grafana Monitoring**
- **Kubernetes Cluster (kubeadm + containerd)**
- **Service Exposure via NodePort & Ingress**

> 📌 Candidate: **Jotheeshwaran V**  
> 📧 Email: [jotheeshwaranv2002@gmail.com](mailto:jotheeshwaranv2002@gmail.com)  
> 🔗 [LinkedIn](https://linkedin.com/in/jotheeshwaran-v) | 🌐 [Portfolio](https://unique-crepe-5ea0e0.netlify.app)

---

## 🏗️ Architecture Diagram

┌─────────────────────────────────────────────────────────────┐
│ Complete Architecture │
├─────────────────────────────────────────────────────────────┤
│ Docker Setup ┌────────────┐ Kubernetes Cluster │
│ ┌────────────┐ │ OpenSearch │ ┌────────────┐ │
│ │ Dashboards │ │ Cluster │ │ StatefulSet│ │
│ └────────────┘ └────────────┘ └────────────┘ │
│ │ │ │ │
│ ┌────────────┐ ┌────────────┐ ┌────────────┐ │
│ │ Prometheus │◄────►│ Node Export│ │ Grafana │ │
└─────────────────────────────────────────────────────────────┘


🏗️ Architecture Diagram

┌─────────────────────────────────────────────────────────────┐
│                    Complete Architecture                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   Docker Setup  │    │  K8s Cluster    │                │
│  │                 │    │                 │                │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                │
│  │ │ OpenSearch  │ │    │ │ OpenSearch  │ │                │
│  │ │  Cluster    │ │    │ │  Cluster    │ │                │
│  │ └─────────────┘ │    │ └─────────────┘ │                │
│  │       │         │    │       │         │                │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                │
│  │ │ Prometheus  │ │    │ │ Prometheus  │ │                │
│  │ │  & Grafana  │ │    │ │  & Grafana  │ │                │
│  │ └─────────────┘ │    │ └─────────────┘ │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                       │                        │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              containerd Runtime                         ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘


📁 Repository Structure

formcept-devops-assessment/
├── README.md
├── docs/
│   ├── 01-container-fundamentals.md
│   ├── 02-docker-setup.md
│   ├── 03-opensearch-docker.md
│   ├── 04-monitoring-setup.md
│   ├── 05-kubernetes-setup.md
│   ├── 06-opensearch-k8s.md
│   └── 07-service-exposure.md
├── docker/
│   ├── docker-compose.yml
│   ├── opensearch/
│   │   ├── opensearch.yml
│   │   └── opensearch-dashboards.yml
│   └── monitoring/
│       ├── prometheus.yml
│       └── grafana/
│           └── dashboards/
├── kubernetes/
│   ├── setup/
│   │   ├── kubeadm-config.yaml
│   │   └── cluster-setup.sh
│   ├── opensearch/
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── monitoring/
│       ├── prometheus/
│       └── grafana/
├── scripts/
│   ├── setup-docker.sh
│   ├── setup-kubernetes.sh
│   ├── deploy-opensearch.sh
│   └── cleanup.sh
└── troubleshooting/
    ├── common-issues.md
    └── solutions.md



🎯 Task Implementation
Task 1: Container Fundamentals
Understanding Core Concepts:

chroot: Process isolation at filesystem level
Container Runtime: Low-level container execution (runc, crun)
Container Engine: High-level container management (Docker, Podman)

Key Learning Points:

Containers share the host kernel but provide process isolation
containerd acts as the industry-standard container runtime
Docker Engine uses containerd as its runtime backend

Task 2: Docker Engine with containerd
Implementation Details:

Configured Docker daemon with containerd runtime
Enabled Docker API and containerd socket
Verified container runtime chain: Docker → containerd → runc

Configuration Files:
json{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2",
  "runtimes": {
    "runc": {
      "path": "runc"
    }
  }
}
Task 3: OpenSearch with Docker Compose
Features Implemented:

Multi-node OpenSearch cluster (3 nodes)
OpenSearch Dashboards integration
Persistent volume mapping
Security configurations
Health checks and restart policies

Cluster Configuration:

Node 1: Master + Data node
Node 2: Data node
Node 3: Data node
Dashboard: Management interface

Task 4: Monitoring with Prometheus & Grafana
Monitoring Stack:

Prometheus: Metrics collection and storage
Grafana: Visualization and alerting
OpenSearch Exporter: Custom metrics extraction
Node Exporter: System metrics

Dashboards Included:

OpenSearch Cluster Health
JVM Memory Usage
Search Performance
Indexing Rates
System Resources

Task 5: Kubernetes Cluster with kubeadm
Cluster Specifications:

Master Node: Control plane components
Worker Nodes: Application workloads
CNI Plugin: Flannel for pod networking
Runtime: containerd

Components Deployed:

kube-apiserver
etcd
kube-scheduler
kube-controller-manager
kubelet
kube-proxy

Task 6: OpenSearch on Kubernetes
Kubernetes Resources:

StatefulSet: For persistent OpenSearch nodes
ConfigMap: Configuration management
PersistentVolumes: Data persistence
Services: Internal cluster communication
Secrets: Security credentials

Task 7: Service Exposure
Exposure Methods Implemented:

NodePort Services

Direct access via node IP and port
Suitable for development/testing


Ingress Controller

HTTP/HTTPS load balancing
Domain-based routing
SSL termination




🚀 Quick Start Guide
Prerequisites
bash# System Requirements
- Ubuntu 20.04+ / CentOS 8+
- 4GB RAM minimum (8GB recommended)
- 20GB disk space
- Internet connectivity
1. Clone Repository
bashgit clone https://github.com/jotheeshwaran-v/formcept-devops-assessment.git
cd formcept-devops-assessment
chmod +x scripts/*.sh
2. Setup Docker Environment
bash# Install Docker with containerd
./scripts/setup-docker.sh

# Verify installation
docker --version
docker info | grep -i runtime
3. Deploy OpenSearch with Docker
bash# Start OpenSearch cluster
cd docker/
docker-compose up -d

# Verify cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"
4. Setup Monitoring
bash# Access Grafana
http://localhost:3000
# Default credentials: admin/admin

# Access Prometheus
http://localhost:9090
5. Setup Kubernetes Cluster
bash# Initialize cluster
./scripts/setup-kubernetes.sh

# Verify cluster status
kubectl get nodes
kubectl get pods --all-namespaces
6. Deploy OpenSearch on Kubernetes
bash# Deploy OpenSearch
kubectl apply -f kubernetes/opensearch/

# Check deployment status
kubectl get pods -n opensearch
kubectl get svc -n opensearch
7. Access Services
bash# NodePort access
kubectl get svc -n opensearch
# Access via http://node-ip:nodeport

# Ingress access (if configured)
http://opensearch.local

🔧 Detailed Configuration
Docker Compose Configuration
yamlversion: '3.8'
services:
  opensearch-node1:
    image: opensearchproject/opensearch:2.11.0
    container_name: opensearch-node1
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-node1
      - discovery.seed_hosts=opensearch-node1,opensearch-node2,opensearch-node3
      - cluster.initial_cluster_manager_nodes=opensearch-node1,opensearch-node2,opensearch-node3
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - "DISABLE_INSTALL_DEMO_CONFIG=true"
      - "DISABLE_SECURITY_PLUGIN=true"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-data1:/usr/share/opensearch/data
    ports:
      - 9200:9200
      - 9600:9600
    networks:
      - opensearch-net
Kubernetes StatefulSet
yamlapiVersion: apps/v1
kind: StatefulSet
metadata:
  name: opensearch-cluster
  namespace: opensearch
spec:
  serviceName: opensearch
  replicas: 3
  selector:
    matchLabels:
      app: opensearch
  template:
    metadata:
      labels:
        app: opensearch
    spec:
      containers:
      - name: opensearch
        image: opensearchproject/opensearch:2.11.0
        ports:
        - containerPort: 9200
          name: rest
        - containerPort: 9300
          name: inter-node
        env:
        - name: cluster.name
          value: "k8s-opensearch"
        - name: node.name
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: discovery.seed_hosts
          value: "opensearch-0.opensearch,opensearch-1.opensearch,opensearch-2.opensearch"
        - name: cluster.initial_cluster_manager_nodes
          value: "opensearch-0,opensearch-1,opensearch-2"
        - name: bootstrap.memory_lock
          value: "true"
        - name: OPENSEARCH_JAVA_OPTS
          value: "-Xms512m -Xmx512m"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: data
          mountPath: /usr/share/opensearch/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi

📊 Monitoring & Observability
Prometheus Configuration
yamlglobal:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'opensearch'
    static_configs:
      - targets: ['localhost:9200']
    metrics_path: '/_prometheus/metrics'
    
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
      
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
Grafana Dashboards
Key Metrics Monitored:

Cluster Health Status
Node Performance
Index Operations
Query Performance
JVM Heap Usage
Disk I/O
Network Traffic


🐛 Troubleshooting Guide
Common Issues & Solutions
1. Docker Installation Issues
Problem: Docker daemon fails to start
bash# Check system logs
sudo journalctl -u docker.service

# Common solution
sudo systemctl daemon-reload
sudo systemctl restart docker
2. OpenSearch Bootstrap Failures
Problem: Cluster fails to form
bash# Check container logs
docker logs opensearch-node1

# Common issues:
# - Memory lock settings
# - Discovery configuration
# - Port conflicts
Solution:
bash# Update system limits
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Fix memory lock
sudo systemctl edit docker
# Add:
[Service]
LimitMEMLOCK=infinity
3. Kubernetes Cluster Issues
Problem: kubeadm init fails
bash# Check system requirements
sudo kubeadm config images list
sudo kubeadm config images pull

# Reset and retry
sudo kubeadm reset
sudo kubeadm init --config=kubeadm-config.yaml
4. Pod Scheduling Issues
Problem: Pods stuck in Pending state
bash# Check node status
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Common solutions:
# - Resource constraints
# - Taints/tolerations
# - PVC issues
5. Service Connectivity Issues
Problem: Cannot access services
bash# Check service endpoints
kubectl get endpoints -n <namespace>

# Check network policies
kubectl get networkpolicies -n <namespace>

# Test connectivity
kubectl run test-pod --image=busybox -it --rm -- /bin/sh
# From inside pod: wget -qO- http://service-name:port

🧪 Testing & Validation
Docker Environment Tests
bash# Test OpenSearch cluster
curl -X GET "localhost:9200/_cluster/health?pretty"
curl -X GET "localhost:9200/_cat/nodes?v"

# Test indexing
curl -X POST "localhost:9200/test-index/_doc/1" \
  -H 'Content-Type: application/json' \
  -d '{"message": "Hello OpenSearch"}'

# Test search
curl -X GET "localhost:9200/test-index/_search?pretty"
Kubernetes Environment Tests
bash# Test cluster health
kubectl get componentstatuses
kubectl get nodes -o wide

# Test OpenSearch deployment
kubectl get pods -n opensearch
kubectl logs -f opensearch-0 -n opensearch

# Test service connectivity
kubectl port-forward svc/opensearch 9200:9200 -n opensearch
curl -X GET "localhost:9200/_cluster/health?pretty"
Monitoring Tests
bash# Test Prometheus targets
curl http://localhost:9090/api/v1/targets

# Test Grafana API
curl -u admin:admin http://localhost:3000/api/health

📈 Performance Optimization
Docker Optimizations
yaml# Resource limits in docker-compose
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 1G
Kubernetes Optimizations
yaml# Resource requests and limits
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"

# Pod disruption budgets
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: opensearch-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: opensearch

🔐 Security Considerations
Docker Security
yaml# Security options
security_opt:
  - no-new-privileges:true
  - seccomp:unconfined

# User namespace remapping
user: "1000:1000"

# Read-only root filesystem
read_only: true
tmpfs:
  - /tmp
  - /var/cache
Kubernetes Security
yaml# Security context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  capabilities:
    drop:
      - ALL
    add:
      - NET_BIND_SERVICE
Network Policies
yamlapiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-netpol
  namespace: opensearch
spec:
  podSelector:
    matchLabels:
      app: opensearch
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: opensearch
    ports:
    - protocol: TCP
      port: 9300
  - from: []
    ports:
    - protocol: TCP
      port: 9200

📚 Learning Resources
Container Fundamentals

Container Runtime Interface
containerd Documentation
Docker Engine Architecture

OpenSearch Resources

OpenSearch Documentation
OpenSearch Kubernetes Operator
Performance Tuning Guide

Kubernetes Resources

Kubernetes Documentation
kubeadm Setup Guide
Kubernetes Networking


🚀 Future Enhancements
Planned Improvements

Helm Charts: Package applications for easier deployment
CI/CD Pipeline: Automated testing and deployment
Multi-Region Setup: Cross-region cluster deployment
Advanced Monitoring: Custom metrics and alerting rules
Backup & Recovery: Automated backup strategies
Security Hardening: RBAC, Pod Security Standards
Load Testing: Performance benchmarking tools

Additional Features

Service Mesh: Istio integration for advanced traffic management
GitOps: ArgoCD for declarative deployments
Observability: Distributed tracing with Jaeger
Cost Optimization: Resource utilization monitoring


📞 Contact & Support
Candidate Information:

Name: Jotheeshwaran V
Email: Jotheeshwaranv2002@gmail.com
Phone: +91 8667782566
LinkedIn: linkedin.com/in/jotheeshwaran-v
Portfolio: unique-crepe-5ea0e0.netlify.app

Repository: GitHub - FORMCEPT DevOps Assessment

📄 License
This project is created for educational and assessment purposes as part of the FORMCEPT DevOps Internship application process.

🙏 Acknowledgments

FORMCEPT Team for providing this comprehensive assessment opportunity
OpenSearch Community for excellent documentation and support
Kubernetes Community for robust orchestration platform
Prometheus & Grafana teams for powerful monitoring solutions


This assessment demonstrates comprehensive understanding of modern DevOps practices, containerization technologies, and cloud-native architectures. The implementation showcases production-ready configurations with proper error handling, monitoring, and documentation.
