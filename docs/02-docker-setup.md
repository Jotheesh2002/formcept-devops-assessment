

### Docker Engine Installation

#### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker run hello-world
```

#### CentOS/RHEL/Rocky Linux

```bash
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo docker run hello-world
```

#### macOS

```bash
brew install docker docker-compose
# or download from https://docs.docker.com/desktop/mac/install/
docker --version
docker-compose --version
```

#### Windows

```powershell
choco install docker-desktop
# or download from https://docs.docker.com/desktop/windows/install/
docker --version
docker-compose --version
```

### Post-Installation Configuration

#### Linux User Configuration

```bash
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

#### System Requirements for OpenSearch

```bash
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "default-ulimits": {
    "memlock": {
      "name": "memlock",
      "soft": -1,
      "hard": -1
    },
    "nofile": {
      "name": "nofile",
      "soft": 65536,
      "hard": 65536
    }
  }
}
EOF

sudo systemctl restart docker
```

### Docker Compose Installation

#### Linux (Standalone)

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
```

#### Using Package Manager

```bash
# Ubuntu/Debian
sudo apt-get install docker-compose-plugin

# CentOS/RHEL
sudo yum install docker-compose-plugin
docker compose version
```

### Docker Configuration for OpenSearch

#### Memory and Swap Configuration

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo 'vm.overcommit_memory=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### Docker Network Setup

```bash
docker network create opensearch-net
docker network ls
docker network inspect opensearch-net
```

#### Storage Configuration

```bash
sudo mkdir -p /opt/opensearch/{data,logs,config}
sudo chown -R 1000:1000 /opt/opensearch/
sudo chmod -R 755 /opt/opensearch/
```

#### Environment Setup

```bash
cat > .env <<EOF
OPENSEARCH_VERSION=latest
OPENSEARCH_INITIAL_ADMIN_PASSWORD=MyStrongPassword123!
OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g
CLUSTER_NAME=opensearch-cluster
DISCOVERY_TYPE=zen
OPENSEARCH_NETWORK=opensearch-net
OPENSEARCH_DATA_PATH=/opt/opensearch/data
OPENSEARCH_LOGS_PATH=/opt/opensearch/logs
OPENSEARCH_CONFIG_PATH=/opt/opensearch/config
EOF
```

#### Directory Structure

```bash
mkdir -p opensearch-docker/{config,data,logs,scripts}
cd opensearch-docker
tree
```

### Docker Resource Limits

#### System Resource Configuration

```bash
ulimit -a
ulimit -n 65536
ulimit -u 4096
ulimit -l unlimited

cat >> ~/.bashrc <<EOF
ulimit -n 65536
ulimit -u 4096
ulimit -l unlimited
EOF
```

#### Docker Resource Management

```yaml
version: '3.8'
services:
  opensearch-node1:
    image: opensearchproject/opensearch:latest
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
        reservations:
          memory: 2G
          cpus: '1.0'
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
```

### Security Configuration

#### Docker Security Best Practices

```bash
dockerd-rootless-setuptool.sh install
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
export DOCKER_CONTENT_TRUST=1
docker scan opensearchproject/opensearch:latest
```

#### SSL/TLS Configuration

```bash
mkdir -p /etc/docker/certs.d/
openssl genrsa -aes256 -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem

sudo tee /etc/docker/daemon.json <<EOF
{
  "hosts": ["tcp://0.0.0.0:2376", "unix:///var/run/docker.sock"],
  "tls": true,
  "tlscert": "/etc/docker/certs.d/server-cert.pem",
  "tlskey": "/etc/docker/certs.d/server-key.pem",
  "tlsverify": true,
  "tlscacert": "/etc/docker/certs.d/ca.pem"
}
EOF
```

### Verification and Testing

#### Installation Verification

```bash
docker --version
docker-compose --version
docker info
docker system df
docker system info
docker run --rm -it ubuntu:latest echo "Docker is working!"
```

#### OpenSearch Specific Tests

```bash
docker run --rm opensearchproject/opensearch:latest \
  bash -c 'echo "Memory limit test: $(ulimit -l)"'

docker run --rm opensearchproject/opensearch:latest \
  bash -c 'echo "File descriptor limit: $(ulimit -n)"'

docker run --rm --network opensearch-net \
  opensearchproject/opensearch:latest \
  ping -c 3 google.com
```

### Maintenance and Monitoring

```bash
docker system prune -af
docker volume prune -f
docker stats
docker logs -f container_name

docker run --rm -v opensearch_data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/opensearch-backup.tar.gz /data
```

### Performance Tuning

```bash
sudo tee /etc/docker/daemon.json <<EOF
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "default-ulimits": {
    "memlock": {
      "soft": -1,
      "hard": -1
    },
    "nofile": {
      "soft": 65536,
      "hard": 65536
    }
  },
  "live-restore": true
}
EOF

sudo systemctl restart docker
```

### Troubleshooting

#### Common Issues

```bash
sudo chown -R $USER:$USER ~/.docker/
sudo systemctl status docker
sudo journalctl -u docker.service
docker network ls
docker network inspect bridge
docker system df
docker volume ls
```

#### OpenSearch Specific Issues

```bash
sysctl vm.max_map_count
docker run --rm opensearchproject/opensearch:latest cat /proc/meminfo
docker run --rm opensearchproject/opensearch:latest ulimit -n
docker run --rm -e "discovery.type=single-node" opensearchproject/opensearch:latest
```

✅ Your Docker environment is now configured and ready for OpenSearch deployment!
