

## 📦 OpenSearch on Kubernetes

### 🎯 Purpose

Deploy OpenSearch cluster on Kubernetes with scaling and persistence

---

### 📁 ConfigMap for OpenSearch Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: opensearch-config
  namespace: opensearch
data:
  opensearch.yml: |
    cluster.name: opensearch-k8s
    network.host: 0.0.0.0
    discovery.seed_hosts: opensearch-cluster-0.opensearch,opensearch-cluster-1.opensearch,opensearch-cluster-2.opensearch
    cluster.initial_cluster_manager_nodes: opensearch-cluster-0,opensearch-cluster-1,opensearch-cluster-2
    plugins.security.disabled: false
    plugins.security.ssl.http.enabled: true
    plugins.security.ssl.transport.enabled: true
```

---

### 🧱 StatefulSet Deployment

```yaml
apiVersion: apps/v1
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
        image: opensearchproject/opensearch:latest
        ports:
        - containerPort: 9200
          name: http
        - containerPort: 9300
          name: transport
        env:
        - name: cluster.name
          value: "opensearch-k8s"
        - name: node.name
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: OPENSEARCH_INITIAL_ADMIN_PASSWORD
          value: "MyStrongPassword123!"
        - name: OPENSEARCH_JAVA_OPTS
          value: "-Xms1g -Xmx1g"
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: opensearch-data
          mountPath: /usr/share/opensearch/data
        - name: opensearch-config
          mountPath: /usr/share/opensearch/config/opensearch.yml
          subPath: opensearch.yml
      volumes:
      - name: opensearch-config
        configMap:
          name: opensearch-config
      initContainers:
      - name: configure-sysctl
        image: busybox
        command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
        securityContext:
          privileged: true
  volumeClaimTemplates:
  - metadata:
      name: opensearch-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

---

### 🌐 Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: opensearch
  namespace: opensearch
spec:
  clusterIP: None
  selector:
    app: opensearch
  ports:
  - port: 9200
    name: http
  - port: 9300
    name: transport
```

---

### 📊 OpenSearch Dashboards

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opensearch-dashboards
  namespace: opensearch
spec:
  replicas: 1
  selector:
    matchLabels:
      app: opensearch-dashboards
  template:
    metadata:
      labels:
        app: opensearch-dashboards
    spec:
      containers:
      - name: opensearch-dashboards
        image: opensearchproject/opensearch-dashboards:latest
        ports:
        - containerPort: 5601
        env:
        - name: OPENSEARCH_HOSTS
          value: "https://opensearch-cluster-0.opensearch:9200"
        - name: OPENSEARCH_USERNAME
          value: "admin"
        - name: OPENSEARCH_PASSWORD
          value: "MyStrongPassword123!"
---
apiVersion: v1
kind: Service
metadata:
  name: opensearch-dashboards
  namespace: opensearch
spec:
  selector:
    app: opensearch-dashboards
  ports:
  - port: 5601
    targetPort: 5601
```

---

### 🚀 Deployment Commands

```bash
# Apply all configurations
kubectl apply -f opensearch-config.yaml
kubectl apply -f opensearch-statefulset.yaml
kubectl apply -f opensearch-service.yaml
kubectl apply -f opensearch-dashboards.yaml

# Check deployment status
kubectl get pods -w
kubectl get pvc
kubectl get svc

# View logs
kubectl logs opensearch-cluster-0
kubectl logs deployment/opensearch-dashboards

# Scale cluster
kubectl scale statefulset opensearch-cluster --replicas=5
```

---

### ✅ Verification

```bash
# Port forward to access cluster
kubectl port-forward svc/opensearch 9200:9200

# Test cluster health
curl -u admin:MyStrongPassword123! -k https://localhost:9200/_cluster/health?pretty

# Access dashboards
kubectl port-forward svc/opensearch-dashboards 5601:5601
# Visit: http://localhost:5601
```

---

### 🧯 Troubleshooting

```bash
# Check pod events
kubectl describe pod opensearch-cluster-0

# Check persistent volumes
kubectl get pv,pvc

# Check resource usage
kubectl top pods

# Emergency pod restart
kubectl delete pod opensearch-cluster-0
```

✅ Your OpenSearch cluster is now running on Kubernetes with persistent storage and high availability!
