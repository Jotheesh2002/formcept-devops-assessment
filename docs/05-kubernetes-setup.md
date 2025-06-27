
## ☸️ Kubernetes Cluster Setup

### Purpose

Set up Kubernetes cluster for container orchestration

### 🧰 Local Development Setup

#### Minikube Installation

```bash
# Install minikube (Linux)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start cluster
minikube start --memory=4096 --cpus=2 --driver=docker

# Verify
kubectl cluster-info
kubectl get nodes
```

#### Kind (Alternative)

```bash
# Install kind
go install sigs.k8s.io/kind@latest

# Create cluster
kind create cluster --name opensearch-cluster

# Verify
kubectl cluster-info --context kind-opensearch-cluster
```

---

### 🛠️ Essential Setup

#### Create Namespace

```bash
kubectl create namespace opensearch
kubectl config set-context --current --namespace=opensearch
```

#### Basic Resource Limits (`resource-quota.yaml`)

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: opensearch-quota
  namespace: opensearch
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    persistentvolumeclaims: "10"
```

#### Storage Class (`storageclass.yaml`)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: opensearch-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
```

#### Quick Commands

```bash
# Apply configurations
kubectl apply -f resource-quota.yaml
kubectl apply -f storageclass.yaml

# Check cluster status
kubectl get nodes -o wide
kubectl get namespaces
kubectl describe namespace opensearch

# Useful commands
kubectl top nodes
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl config current-context
```

---

### 🧩 Preparation for OpenSearch

#### System Settings (`opensearch-prep.yaml`)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: opensearch-prep
spec:
  selector:
    matchLabels:
      name: opensearch-prep
  template:
    metadata:
      labels:
        name: opensearch-prep
    spec:
      hostPID: true
      hostNetwork: true
      containers:
      - name: opensearch-prep
        image: busybox
        command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144 && sleep infinity']
        securityContext:
          privileged: true
```

#### Apply and Verify

```bash
kubectl apply -f opensearch-prep.yaml
kubectl get ds opensearch-prep
```

✅ Your cluster is now ready for OpenSearch deployment!

