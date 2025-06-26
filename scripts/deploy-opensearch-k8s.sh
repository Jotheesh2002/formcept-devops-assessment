#!/bin/bash

# Script to deploy OpenSearch on Kubernetes

set -e

echo "⚓ Deploying OpenSearch on Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster is not accessible"
    exit 1
fi

# Create namespace
echo "📁 Creating opensearch namespace..."
kubectl apply -f kubernetes/namespace.yaml

# Deploy OpenSearch master nodes
echo "🔄 Deploying OpenSearch master nodes..."
kubectl apply -f kubernetes/opensearch/opensearch-master.yaml

# Wait for OpenSearch pods to be ready
echo "⏳ Waiting for OpenSearch pods to be ready..."
kubectl wait --for=condition=ready pod -l app=opensearch-master -n opensearch --timeout=300s

# Deploy OpenSearch Dashboards
echo "📊 Deploying OpenSearch Dashboards..."
kubectl apply -f kubernetes/opensearch/opensearch-dashboards.yaml

# Deploy monitoring stack
echo "📈 Deploying Prometheus and Grafana..."
kubectl apply -f kubernetes/monitoring/prometheus.yaml
kubectl apply -f kubernetes/monitoring/grafana.yaml

# Deploy Ingress
echo "🌐 Deploying Ingress resources..."
kubectl apply -f kubernetes/ingress/opensearch-ingress.yaml

# Wait for all deployments to be ready
echo "⏳ Waiting for all deployments to be ready..."
kubectl wait --for=condition=available deployment --all -n opensearch --timeout=300s

# Add hosts entries for ingress
echo "🔧 Adding hosts entries for Ingress..."
echo "# OpenSearch Ingress hosts" | sudo tee -a /etc/hosts
echo "127.0.0.1 opensearch.local" | sudo tee -a /etc/hosts
echo "127.0.0.1 dashboards.local" | sudo tee -a /etc/hosts
echo "127.0.0.1 grafana.local" | sudo tee -a /etc/hosts
echo "127.0.0.1 prometheus.local" | sudo tee -a /etc/hosts

echo ""
echo "✅ OpenSearch deployment completed!"
echo ""
echo "🌐 Access via NodePorts:"
echo "   OpenSearch: http://localhost:30920"
echo "   OpenSearch Dashboards: http://localhost:30561"
echo "   Prometheus: http://localhost:30900"
echo "   Grafana: http://localhost:30300 (admin/admin)"
echo ""
echo "🌐 Access via Ingress (add to /etc/hosts):"
echo "   OpenSearch: http://opensearch.local"
echo "   OpenSearch Dashboards: http://dashboards.local"
echo "   Prometheus: http://prometheus.local"
echo "   Grafana: http://grafana.local"
echo ""
echo "🔍 Check cluster status:"
echo "   kubectl get pods -n opensearch"
echo "   kubectl port-forward -n opensearch svc/opensearch-master 9200:9200"
