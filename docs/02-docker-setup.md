
## 🐳 Docker Engine Setup with containerd

### Overview

Production-ready Docker installation with containerd runtime backend, security hardening, and performance optimization.

### Installation Process

#### 1. System Preparation

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common
```

#### 2. Docker Repository Setup

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### 3. Docker Engine Installation

```bash
sudo apt-get update
sudo apt-get install -y \
    docker-ce=5:24.0.5-1~ubuntu.20.04~focal \
    docker-ce-cli=5:24.0.5-1~ubuntu.20.04~focal \
    containerd.io=1.6.21-1

sudo apt-mark hold docker-ce docker-ce-cli containerd.io
```

### Production Configuration

#### 1. Docker Daemon Configuration

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3",
    "compress": "true"
  },
  "storage-driver": "overlay2",
  "storage-opts": ["overlay2.override_kernel_check=true"],
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "icc": false,
  "default-ulimits": {
    "nofile": {"hard": 65536, "soft": 65536}
  },
  "registry-mirrors": ["https://mirror.gcr.io"],
  "metrics-addr": "127.0.0.1:9323",
  "experimental": false,
  "features": {"buildkit": true}
}
EOF
```

#### 2. containerd Configuration

```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's|sandbox_image = ".*"|sandbox_image = "registry.k8s.io/pause:3.9"|' /etc/containerd/config.toml
```

#### 3. Service Management

```bash
sudo systemctl daemon-reload
sudo systemctl enable containerd docker
sudo systemctl start containerd docker
sudo usermod -aG docker $USER
newgrp docker

docker --version
docker info
containerd --version
```

### Verification & Testing

#### 1. Basic Functionality Test

```bash
docker run hello-world
sudo ctr images pull docker.io/library/alpine:latest
sudo ctr run --rm docker.io/library/alpine:latest test-container echo "Hello from containerd"
```

#### 2. Performance Verification

```bash
docker system info
docker system df
curl http://127.0.0.1:9323/metrics
docker build --help | grep buildkit
DOCKER_BUILDKIT=1 docker build .
```

### Common Issues & Solutions

#### Issue 1: Docker Service Won't Start

```bash
sudo systemctl status docker
sudo journalctl -u docker.service -f
sudo mv /etc/docker/daemon.json /etc/docker/daemon.json.backup
sudo systemctl restart docker
```

#### Issue 2: Permission Denied

```bash
groups $USER
sudo usermod -aG docker $USER
newgrp docker
sudo chmod 666 /var/run/docker.sock
sudo systemctl restart docker
```

#### Issue 3: containerd Conflicts

```bash
sudo systemctl status containerd
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl restart docker
sudo ctr version
```

#### Issue 4: Storage Issues

```bash
docker system df
docker system prune -af
docker info | grep "Storage Driver"
docker volume prune -f
```

#### Issue 5: Network Problems

```bash
docker run --rm alpine nslookup docker.io
docker run --rm alpine ping -c 3 8.8.8.8
docker network prune -f
sudo systemctl restart docker
```

### Docker Compose Installation

```bash
COMPOSE_VERSION="2.20.2"
sudo curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
docker compose version
```

### Security Hardening

#### 1. User Namespace Remapping

```bash
"userns-remap": "default"
echo "dockremap:165536:65536" | sudo tee -a /etc/subuid
echo "dockremap:165536:65536" | sudo tee -a /etc/subgid
sudo systemctl restart docker
```

#### 2. AppArmor/SELinux Integration

```bash
sudo aa-status | grep docker
sudo apparmor_parser -r -W /etc/apparmor.d/docker
```

#### 3. Audit Logging

```bash
docker events --since '2024-01-01' --until '2024-12-31' \
    --filter type=container --format 'json' > docker-audit.log
```

### Performance Tuning

#### 1. System Optimizations

```bash
echo "fs.file-max = 65536" | sudo tee -a /etc/sysctl.conf
echo "net.core.somaxconn = 1024" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 1024 65535" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### 2. Docker-specific Tuning

```bash
export DOCKER_CLI_EXPERIMENTAL=enabled
export DOCKER_BUILDKIT=1
docker builder prune --filter until=24h
```

### Monitoring Setup

```bash
curl http://127.0.0.1:9323/metrics
docker run -d \
    --name=docker-stats \
    --restart=unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /proc:/host/proc:ro \
    -v /sys:/host/sys:ro \
    prom/node-exporter
```

### 🧠 Best Practices

* Always pin Docker versions in production
* Use multi-stage builds to reduce image size
* Enable BuildKit for faster builds
* Configure log rotation to prevent disk filling
* Use health checks in containers
* Implement resource limits on containers
* Regular security updates and vulnerability scanning

### 📌 Next Steps

* Deploy multi-container applications with Docker Compose
* Implement container orchestration with Kubernetes
* Set up container image scanning and security policies

