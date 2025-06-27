

## 🌐 Expose OpenSearch Services on Kubernetes

### 🎯 Purpose

Expose OpenSearch services for external access using various Kubernetes service types

---

### 🔌 NodePort Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: opensearch-nodeport
  namespace: opensearch
spec:
  type: NodePort
  selector:
    app: opensearch
  ports:
  - port: 9200
    targetPort: 9200
    nodePort: 30920
    name: http
  - port: 5601
    targetPort: 5601
    nodePort: 30561
    name: dashboards
```

**Access:**

```bash
# Get node IP
kubectl get nodes -o wide

# Access OpenSearch
curl -u admin:MyStrongPassword123! -k https://<NODE_IP>:30920

# Access Dashboards
# Visit: http://<NODE_IP>:30561
```

---

### ☁️ LoadBalancer Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: opensearch-lb
  namespace: opensearch
spec:
  type: LoadBalancer
  selector:
    app: opensearch
  ports:
  - port: 9200
    targetPort: 9200
    name: http
  - port: 5601
    targetPort: 5601
    name: dashboards
```

**Access:**

```bash
# Get external IP
kubectl get svc opensearch-lb

# Access via external IP
curl -u admin:MyStrongPassword123! -k https://<EXTERNAL_IP>:9200
```

---

### 🌐 Ingress Controller

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: opensearch-ingress
  namespace: opensearch
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - opensearch.example.com
    - dashboards.example.com
    secretName: opensearch-tls
  rules:
  - host: opensearch.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: opensearch
            port:
              number: 9200
  - host: dashboards.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: opensearch-dashboards
            port:
              number: 5601
```

**Install Ingress Controller:**

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
kubectl get pods -n ingress-nginx
```

---

### 🧪 Port Forwarding (Development)

```bash
# Forward OpenSearch
kubectl port-forward svc/opensearch 9200:9200 &

# Forward Dashboards
kubectl port-forward svc/opensearch-dashboards 5601:5601 &

# Access locally
curl -u admin:MyStrongPassword123! -k https://localhost:9200
# Visit: http://localhost:5601
```

---

### 🔐 SSL/TLS Certificate Setup

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: opensearch-tls
  namespace: opensearch
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

**Generate and Apply TLS Secret:**

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=opensearch.example.com"

kubectl create secret tls opensearch-tls \
  --cert=tls.crt --key=tls.key \
  -n opensearch
```

---

### 📡 Service Mesh (Istio Gateway)

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: opensearch-gateway
  namespace: opensearch
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: opensearch-tls
    hosts:
    - opensearch.example.com
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: opensearch-vs
  namespace: opensearch
spec:
  hosts:
  - opensearch.example.com
  gateways:
  - opensearch-gateway
  http:
  - route:
    - destination:
        host: opensearch
        port:
          number: 9200
```

---

### 📌 Quick Commands

```bash
kubectl apply -f opensearch-nodeport.yaml
kubectl apply -f opensearch-loadbalancer.yaml
kubectl apply -f opensearch-ingress.yaml

kubectl get svc -n opensearch
kubectl get ingress -n opensearch
kubectl get endpoints -n opensearch
kubectl describe svc opensearch-lb
kubectl describe ingress opensearch-ingress
```

---

### 📚 Access Summary

| Method       | Use Case               | Access                           |
| ------------ | ---------------------- | -------------------------------- |
| NodePort     | Simple external access | `<NodeIP>:<NodePort>`            |
| LoadBalancer | Cloud environments     | `<ExternalIP>:<Port>`            |
| Ingress      | Domain-based routing   | `https://opensearch.example.com` |
| Port Forward | Development/debugging  | `localhost:<Port>`               |

✅ Choose the method that best fits your environment and security requirements!

