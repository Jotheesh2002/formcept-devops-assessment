# formcept-devops-assessment

Container Basics Documentation
docs/01-container-basics.md
Understanding Containers
Containers are lightweight, portable, and self-sufficient units that package applications with their dependencies. They provide process isolation and resource management.
Key Concepts:
1. chroot (Change Root)

Creates an isolated filesystem environment
Changes the root directory for a process
Provides basic filesystem isolation
Foundation for modern containerization

bash# Example chroot usage
sudo mkdir /tmp/jail
sudo cp /bin/bash /tmp/jail/
sudo chroot /tmp/jail /bash
2. Container Runtime

Low-level component that runs containers
Examples: runc, crun, kata-runtime
Implements OCI (Open Container Initiative) specification
Manages container lifecycle (create, start, stop, delete)

3. Container Engine

High-level interface for container management
Examples: Docker Engine, Podman, containerd
Provides API and CLI tools
Manages images, networks, volumes

Architecture Overview:
┌─────────────────┐
│   Docker CLI    │ (User Interface)
├─────────────────┤
│  Docker Engine  │ (Container Engine)
├─────────────────┤
│   containerd    │ (Container Runtime - High Level)
├─────────────────┤
│      runc       │ (Container Runtime - Low Level)
├─────────────────┤
│  Linux Kernel   │ (namespaces, cgroups)
└─────────────────┘

docs/02-docker-setup.md
Docker Engine Setup with containerd
This guide covers setting up Docker Engine with containerd as the container runtime.
Prerequisites:

Ubuntu 20.04/22.04 or compatible Linux distribution
Root or sudo access
At least 2GB RAM and 10GB disk space

Installation Steps:

Update System

bashsudo apt-get update
sudo apt-get upgrade -y

Install Dependencies

bashsudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

Add Docker Repository

bashcurl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

Install Docker Engine

bashsudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Configure Docker Daemon

bashsudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

Configure containerd

bashsudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
Verification:
bashdocker --version
docker info | grep -i runtime
sudo systemctl status docker
sudo systemctl status containerd

docs/03-opensearch-docker.md
OpenSearch Deployment with Docker Compose
OpenSearch is a distributed search and analytics engine. This guide covers deploying a 3-node cluster using Docker Compose.
Architecture:

3 OpenSearch nodes (master-eligible and data nodes)
OpenSearch Dashboards for visualization
Persistent storage for data
Network isolation

Configuration Highlights:
Memory Settings:

bootstrap.memory_lock=true: Locks JVM memory
OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m: JVM heap size
vm.max_map_count=262144: Kernel memory mapping

Cluster Discovery:

discovery.seed_hosts: Initial nodes for cluster formation
cluster.initial_cluster_manager_nodes: Bootstrap nodes
cluster.name: Unique cluster identifier

Security:

DISABLE_SECURITY_PLUGIN=true: Disabled for simplicity
Production deployments should enable security

Deployment Commands:
bashcd docker-compose
docker-compose up -d
docker-compose logs -f opensearch-node1
Health Checks:
bashcurl -X GET "localhost:9200/_cat/nodes?v&pretty"
curl -X GET "localhost:9200/_cluster/health?pretty"
curl -X GET "localhost:9200/_cat/indices?v&pretty"

docs/04-monitoring-setup.md
Monitoring Stack Setup
Comprehensive monitoring setup using Prometheus and Grafana to monitor OpenSearch cluster performance and health.
Components:

Prometheus: Metrics collection and storage
Grafana: Visualization and dashboards
Node Exporter: System metrics collection
OpenSearch Metrics: Cluster-specific metrics

Prometheus Configuration:
yamlscrape_configs:
  - job_name: 'opensearch'
    static_configs:
      - targets: ['opensearch-node1:9200']
    metrics_path: '/_prometheus/metrics'
    scrape_interval: 30s
Key Metrics to Monitor:

Cluster Health: Green/Yellow/Red status
Node Performance: CPU, memory, disk usage
Index Performance: Search/indexing rates
JVM Metrics: Heap usage, garbage collection
Network Metrics: Request rates, response times

Grafana Dashboards:

OpenSearch Cluster Overview
Node Performance Metrics
Index Statistics
System Resource Usage

Alerts Configuration:

Cluster health degradation
High memory usage
Disk space warnings
Node connectivity issues


docs/05-kubernetes-setup.md
Kubernetes Cluster Setup with kubeadm
Setting up a single-node Kubernetes cluster using kubeadm with containerd as the container runtime.
Prerequisites:

2 CPUs minimum
2GB RAM minimum
Network connectivity
Swap disabled

Installation Steps:

Prepare System

bash# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

Configure Networking

bashcat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

Install Kubernetes Components

bashcurl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

Initialize Cluster

bashsudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock

Configure kubectl

bashmkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Install CNI (Flannel)

bashkubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
Verification:
bashkubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info

docs/06-opensearch-k8s.md
OpenSearch Deployment on Kubernetes
Deploying OpenSearch cluster on Kubernetes using StatefulSets, Services, and persistent storage.
Kubernetes Resources:

Namespace: Logical isolation for OpenSearch resources
StatefulSet: Manages OpenSearch master nodes with persistent storage
Services: Exposes OpenSearch cluster internally and externally
ConfigMaps: Configuration management
PersistentVolumeClaims: Data persistence

Key Configurations:
StatefulSet Features:

Ordered deployment and scaling
Stable network identities
Persistent storage per pod
Controlled rolling updates

Resource Management:
yamlresources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
Storage Configuration:
yamlvolumeClaimTemplates:
- metadata:
    name: opensearch-data
  spec:
    accessModes: ["ReadWriteOnce"]
    resources:
      requests:
        storage: 10Gi
Deployment Commands:
bashkubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/opensearch/
kubectl get pods -n opensearch -w
Scaling Operations:
bash# Scale up
kubectl scale statefulset opensearch-master --replicas=5 -n opensearch

# Scale down
kubectl scale statefulset opensearch-master --replicas=3 -n opensearch

docs/07-expose-services.md
Exposing OpenSearch Services
Multiple methods to expose OpenSearch cluster services to external access.
Method 1: NodePort Services
Exposes services on static ports on each node.
yamlapiVersion: v1
kind: Service
metadata:
  name: opensearch-master
spec:
  type: NodePort
  ports:
  - port: 9200
    targetPort: 9200
    nodePort: 30920
Advantages:

Simple configuration
Works without additional components
Direct access via node IPs

Disadvantages:

Limited port range (30000-32767)
Requires firewall configuration
Not ideal for production

Method 2: Ingress Resources
Uses Ingress Controller for HTTP/HTTPS routing.
yamlapiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: opensearch-ingress
spec:
  rules:
  - host: opensearch.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: opensearch-master
            port:
              number: 9200
Advantages:

Host-based routing
SSL termination
Path-based routing
Production-ready

Requirements:

Ingress Controller (NGINX, Traefik, etc.)
DNS configuration or /etc/hosts entries

Method 3: LoadBalancer (Cloud Environments)
Automatically provisions external load balancer.
yamlapiVersion: v1
kind: Service
metadata:
  name: opensearch-master
spec:
  type: LoadBalancer
  ports:
  - port: 9200
    targetPort: 9200
Access Methods:
bash# NodePort access
curl http://localhost:30920/_cluster/health

# Ingress access (after /etc/hosts configuration)
curl http://opensearch.local/_cluster/health

# Port forwarding for testing
kubectl port-forward -n opensearch svc/opensearch-master 9200:9200
curl http://localhost:9200/_cluster/health
Security Considerations:

Enable authentication in production
Use TLS/SSL for encrypted communication
Implement network policies
Regular security updates
Monitor access logs
