
## ⚙️ OpenSearch Deployment with Docker

### Purpose

Deploy and configure OpenSearch clusters using Docker containers

### 🔹 Single Node Setup

#### Quick Start

```bash
docker run -d \
  --name opensearch-node \
  -p 9200:9200 -p 9600:9600 \
  -e "discovery.type=single-node" \
  -e "OPENSEARCH_INITIAL_ADMIN_PASSWORD=MyStrongPassword123!" \
  -e "DISABLE_SECURITY_PLUGIN=true" \
  opensearchproject/opensearch:latest

curl http://localhost:9200
```

#### With Security Enabled

```bash
docker run -d \
  --name opensearch-secure \
  -p 9200:9200 -p 9600:9600 \
  -e "discovery.type=single-node" \
  -e "OPENSEARCH_INITIAL_ADMIN_PASSWORD=MyStrongPassword123!" \
  -e "bootstrap.memory_lock=true" \
  --ulimit memlock=-1:-1 \
  --ulimit nofile=65536:65536 \
  opensearchproject/opensearch:latest

curl -u admin:MyStrongPassword123! -k https://localhost:9200
```

### 🔹 Multi-Node Cluster using Docker Compose

#### Complete `docker-compose.yml`

```yaml
version: '3.8'
services:
  opensearch-node1:
    image: opensearchproject/opensearch:latest
    container_name: opensearch-node1
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-node1
      - discovery.seed_hosts=opensearch-node1,opensearch-node2,opensearch-node3
      - cluster.initial_cluster_manager_nodes=opensearch-node1,opensearch-node2,opensearch-node3
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g"
      - OPENSEARCH_INITIAL_ADMIN_PASSWORD=MyStrongPassword123!
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-data1:/usr/share/opensearch/data
      - ./config/opensearch.yml:/usr/share/opensearch/config/opensearch.yml:ro
    ports:
      - 9200:9200
      - 9600:9600
    networks:
      - opensearch-net

  opensearch-node2:
    image: opensearchproject/opensearch:latest
    container_name: opensearch-node2
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-node2
      - discovery.seed_hosts=opensearch-node1,opensearch-node2,opensearch-node3
      - cluster.initial_cluster_manager_nodes=opensearch-node1,opensearch-node2,opensearch-node3
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g"
      - OPENSEARCH_INITIAL_ADMIN_PASSWORD=MyStrongPassword123!
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-data2:/usr/share/opensearch/data
      - ./config/opensearch.yml:/usr/share/opensearch/config/opensearch.yml:ro
    networks:
      - opensearch-net

  opensearch-node3:
    image: opensearchproject/opensearch:latest
    container_name: opensearch-node3
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-node3
      - discovery.seed_hosts=opensearch-node1,opensearch-node2,opensearch-node3
      - cluster.initial_cluster_manager_nodes=opensearch-node1,opensearch-node2,opensearch-node3
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g"
      - OPENSEARCH_INITIAL_ADMIN_PASSWORD=MyStrongPassword123!
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - opensearch-data3:/usr/share/opensearch/data
      - ./config/opensearch.yml:/usr/share/opensearch/config/opensearch.yml:ro
    networks:
      - opensearch-net

  opensearch-dashboards:
    image: opensearchproject/opensearch-dashboards:latest
    container_name: opensearch-dashboards
    ports:
      - 5601:5601
    expose:
      - "5601"
    environment:
      - OPENSEARCH_HOSTS=["https://opensearch-node1:9200","https://opensearch-node2:9200","https://opensearch-node3:9200"]
      - OPENSEARCH_USERNAME=admin
      - OPENSEARCH_PASSWORD=MyStrongPassword123!
    networks:
      - opensearch-net
    depends_on:
      - opensearch-node1
      - opensearch-node2
      - opensearch-node3

volumes:
  opensearch-data1:
  opensearch-data2:
  opensearch-data3:

networks:
  opensearch-net:
    driver: bridge
```

#### OpenSearch Configuration (`config/opensearch.yml`)

```yaml
cluster.name: "opensearch-cluster"
network.host: 0.0.0.0
http.port: 9200
transport.port: 9300
discovery.zen.ping.unicast.hosts: ["opensearch-node1", "opensearch-node2", "opensearch-node3"]
discovery.zen.minimum_master_nodes: 2

# Security
plugins.security.ssl.transport.pemcert_filepath: esnode.pem
plugins.security.ssl.transport.pemkey_filepath: esnode-key.pem
plugins.security.ssl.transport.pemtrustedcas_filepath: root-ca.pem
plugins.security.ssl.http.enabled: true
plugins.security.ssl.http.pemcert_filepath: esnode.pem
plugins.security.ssl.http.pemkey_filepath: esnode-key.pem
plugins.security.ssl.http.pemtrustedcas_filepath: root-ca.pem

bootstrap.memory_lock: true
indices.query.bool.max_clause_count: 1024
```

#### Add Dedicated Data-Only Nodes

```yaml
  opensearch-data1:
    image: opensearchproject/opensearch:latest
    container_name: opensearch-data1
    environment:
      - cluster.name=opensearch-cluster
      - node.name=opensearch-data1
      - node.roles=data,ingest
      - discovery.seed_hosts=opensearch-node1,opensearch-node2,opensearch-node3
      - cluster.initial_cluster_manager_nodes=opensearch-node1,opensearch-node2,opensearch-node3
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g"
      - OPENSEARCH_INITIAL_ADMIN_PASSWORD=MyStrongPassword123!
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - opensearch-data-node1:/usr/share/opensearch/data
    networks:
      - opensearch-net
```

### 🔧 Management Commands

#### Cluster Operations

```bash
docker-compose up -d
docker-compose logs -f opensearch-node1
curl -u admin:MyStrongPassword123! -k https://localhost:9200/_cluster/health?pretty
```

#### Cluster Management

```bash
curl -u admin:MyStrongPassword123! -k https://localhost:9200/_cat/nodes?v
curl -u admin:MyStrongPassword123! -k https://localhost:9200/_cat/indices?v
curl -u admin:MyStrongPassword123! -k https://localhost:9200/_cluster/settings?pretty
```

#### Scaling

```bash
docker-compose up -d --scale opensearch-data1=2
curl -u admin:MyStrongPassword123! -k -X PUT https://localhost:9200/_cluster/settings \
  -H 'Content-Type: application/json' \
  -d '{"transient":{"cluster.routing.allocation.exclude._name":"opensearch-node3"}}'
```

#### Backup and Restore

```bash
docker exec opensearch-node1 mkdir -p /usr/share/opensearch/backup
curl -u admin:MyStrongPassword123! -k -X PUT https://localhost:9200/_snapshot/backup \
  -H 'Content-Type: application/json' \
  -d '{"type":"fs","settings":{"location":"/usr/share/opensearch/backup"}}'
curl -u admin:MyStrongPassword123! -k -X PUT https://localhost:9200/_snapshot/backup/snapshot1
```

#### Troubleshooting

```bash
docker logs opensearch-node1
docker exec opensearch-node1 cat /proc/meminfo
docker-compose restart opensearch-node1
docker exec opensearch-node1 df -h
curl -u admin:MyStrongPassword123! -k https://localhost:9200/_cat/allocation?v
```

---

### 🔗 Access Points

* OpenSearch API: [https://localhost:9200](https://localhost:9200)
* OpenSearch Dashboards: [http://localhost:5601](http://localhost:5601)
* Credentials: `admin / MyStrongPassword123!`

✅ Your OpenSearch cluster is now running with Docker!

