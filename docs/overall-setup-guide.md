## 🚀 OpenSearch Deployment: From Docker to Kubernetes
This guide demonstrates how to understand and deploy OpenSearch using Docker and Kubernetes backed by containerd, and how to monitor it using Prometheus and Grafana.

## 📦 1. Understanding Containers
🔒 chroot: Basic Isolation
bash
Copy code
man chroot
chroot changes the root directory for a process, providing basic filesystem-level isolation — the foundational idea behind containers.


##  Container Engine (Docker)
bash```
Copy code
docker version```
Docker is a container engine that interfaces with containerd to provide CLI and API tools to manage containers.

## 🛠 2. Setup Docker Engine with containerd
✅ Check Docker Engine using containerd
bash
Copy code
docker info | grep -i "containerd"
## ✅ Verify containerd is running
bash
Copy code
## ps aux | grep containerd
## 📦 3. Deploy OpenSearch Cluster with Docker Compose
docker-compose.yml Example
bash
Copy code
cat docker-compose.yml
⬆️ Launch OpenSearch
bash
Copy code
docker-compose up -d
docker ps | grep opensearch
🔍 Test OpenSearch API
bash
Copy code
curl -u admin:admin123 http://localhost:9200
## 📊 4. Monitor with Prometheus + Grafana
✔️ Confirm Services Running
bash
Copy code
docker ps | grep prometheus
docker ps | grep grafana
📍 Prometheus Targets & Grafana Dashboards
Access via browser (update with your local ports):

Prometheus: http://localhost:9090/targets

Grafana: http://localhost:3000

## ☸️ 5. Create Kubernetes Cluster (Kubeadm + containerd)
🚀 Check Cluster & Pods
bash
Copy code
kubectl get nodes
kubectl get pods -A
🔍 Verify Runtime
bash
Copy code
crictl info | grep runtime
If crictl is missing, inspect /var/lib/kubelet/kubeadm-flags.env or use ps aux | grep containerd.

## 🔁 6. Deploy OpenSearch to Kubernetes
📄 View Deployment YAML
bash
Copy code
cat opensearch-deployment.yml
⬆️ Apply Deployment
bash
Copy code
kubectl apply -f opensearch-deployment.yml
kubectl get pods -w
🧾 Logs
bash
Copy code
kubectl logs <opensearch-pod-name>
## 🌐 7. Expose OpenSearch (NodePort / Ingress)
📄 View Service Manifest
bash
Copy code
cat opensearch-service.yml
🔎 View Services
bash
Copy code
kubectl get svc
📡 Test Access (NodePort)
bash
Copy code
curl -u admin:admin123 http://$(minikube ip):<nodeport>
🌍 Or via Ingress
bash
Copy code
curl -u admin:admin123 http://<ingress-host>
🎥 Tips for Sharing Terminal Sessions
Use tmux or screen for clean session sharing.

Record a demo using asciinema or terminalizer.

Prepare all commands before a live run.

Show environment proof:

bash
Copy code
uname -m            # Should say arm64 on M2
minikube status
docker info
kubectl config current-context
🧠 Summary
You now have a complete workflow to:

Understand containers (chroot → containerd → Docker)

Run OpenSearch with Docker Compose

Monitor using Prometheus + Grafana

Deploy OpenSearch in Kubernetes (kubeadm + containerd)

Expose services to local machine via NodePort or Ingress

Let me know if you'd like this saved to a .md file or want to include screenshots, emojis, badges, or visual diagrams!



