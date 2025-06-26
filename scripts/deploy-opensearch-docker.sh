#!/bin/bash

# Script to deploy OpenSearch cluster with Docker Compose

set -e

echo " Deploying OpenSearch cluster with Docker Compose..."

# Navigate to docker-compose directory
cd docker-compose

# Create necessary directories
mkdir -p opensearch prometheus grafana/provisioning/datasources grafana/provisioning/dashboards

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo " Docker is not running. Please start Docker first."
    exit 1
fi

# Pull images first
echo "📥 Pulling Docker images..."
docker-compose pull

# Start the services
echo "🔄 Starting OpenSearch cluster..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check OpenSearch cluster health
echo "🏥 Checking OpenSearch cluster health..."
for i in {1..10}; do
    if curl -s http://localhost:9200/_cluster/health > /dev/null; then
        echo " OpenSearch cluster is healthy!"
        break
    else
        echo "⏳ Waiting for OpenSearch to be ready... (attempt $i/10)"
        sleep 10
    fi
done

# Display service URLs
echo ""
echo "🌐 Services are now available at:"
echo "   OpenSearch: http://localhost:9200"
echo "   OpenSearch Dashboards: http://localhost:5601"
echo "   Prometheus: http://localhost:9090"
echo "   Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "🔍 Check cluster status:"
echo "   curl -X GET 'localhost:9200/_cat/nodes?v&pretty'"
echo "   curl -X GET 'localhost:9200/_cluster/health?pretty'"

---

#!/bin/bash
# scripts/setup-kubernetes.sh
# Script to setup Kubernetes cluster using kubeadm with containerd

set -e

echo "⚓ Setting up Kubernetes cluster with kubeadm and containerd..."

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load required kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set required sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Install kubeadm, kubelet, and kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Configure kubelet to use containerd
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock"
EOF

# Initialize Kubernetes cluster
echo "🔄 Initializing Kubernetes cluster..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock

# Set up kubeconfig for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel CNI
echo " Installing Flannel CNI..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Remove taint from master node (for single-node cluster)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# Install NGINX Ingress Controller
echo "🔧 Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/baremetal/deploy.yaml

# Wait for ingress controller to be ready
echo "⏳ Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo " Kubernetes cluster setup completed!"
echo " Verify cluster status with: kubectl get nodes"
echo " Check all pods with: kubectl get pods --all-namespaces"

