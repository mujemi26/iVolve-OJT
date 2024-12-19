# NGINX Helm Chart Deployment 🚀

Welcome to the **NGINX Helm Chart** repository! This README provides a step-by-step guide to deploy an NGINX server on a Kubernetes cluster using Helm. Follow along to set up, access, and manage the deployment effortlessly.

---

## 📋 Prerequisites

Before you begin, ensure you have the following tools installed:

- **Helm** (v3 or later): [Install Helm](https://helm.sh/docs/intro/install/)
- **kubectl**: [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **Kind** (Kubernetes in Docker): [Install Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- A functional **Kind cluster**:
  ```bash
  kind create cluster
  ```

---

## 📂 Chart Structure

The Helm chart directory is structured as follows:

```
nginx-chart/
├── Chart.yaml       # Chart metadata
├── values.yaml      # Default configuration values
└── templates/       # Kubernetes resource templates
    ├── deployment.yaml
    └── service.yaml
```

### **Chart.yaml**

Defines the chart metadata.

### **values.yaml**

Holds customizable default values for the chart, such as image details and replica count.

### **templates/**

Contains templates for Kubernetes resources like deployments and services.

---

## 🛠️ How to Use This Chart

### **1. Create the Chart**

Clone this repository or create a new Helm chart:

```bash
helm create nginx-chart
```

### **2. Modify Configuration**

Customize `values.yaml` as needed. Example values:

```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.25.0"
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80
  nodePort: 30080

resources: {}
```

### **3. Deploy the Chart**

Install the chart on your Kubernetes cluster:

```bash
helm install nginx-release ./nginx-chart
```

### **4. Verify the Deployment**

Check the pods and services:

```bash
kubectl get pods
kubectl get svc
```

---

![](screenshots/svc%20&%20pods.jpg)

## 🌐 Accessing NGINX

### **Using NodePort**

1. Find the assigned NodePort:
   ```bash
   kubectl get svc nginx-release-nginx-service -o jsonpath="{.spec.ports[0].nodePort}"
   ```
2. Access the service:
   ```bash
   curl http://127.0.0.1:<NodePort>
   ```
   Or visit `http://127.0.0.1:<NodePort>` in your browser.

### **Using Port Forwarding** (Alternative)

Forward a port from your local machine to the service:

```bash
kubectl port-forward svc/nginx-release-nginx-service 8080:80
```

Access the service at `http://127.0.0.1:8080`.

---

## 🧹 Managing the Deployment

### **Upgrade the Chart**

To apply changes to the chart:

```bash
helm upgrade nginx-release ./nginx-chart
```

### **Uninstall the Chart**

Remove the deployment:

```bash
helm uninstall nginx-release
```

Verify deletion:

```bash
kubectl get all
```

---

## 🛡️ Troubleshooting

### **Pending Pods**

If pods remain in `Pending` state:

- Check pod events:
  ```bash
  kubectl describe pod <pod-name>
  ```
- Verify node resource availability:
  ```bash
  kubectl describe nodes
  ```

### **Service Inaccessibility**

- Ensure the service is exposed as `NodePort`:
  ```bash
  kubectl get svc
  ```
- Check Kind networking and port mappings.

### **Pod Logs**

View pod logs for errors:

```bash
kubectl logs <pod-name>
```

---

## 📖 References

- [Helm Documentation](https://helm.sh/docs/)
- [NGINX Docker Hub](https://hub.docker.com/_/nginx)
- [Kind Documentation](https://kind.sigs.k8s.io/docs/)

---

## 🙌 Contributions

Contributions are welcome! Feel free to open issues or submit pull requests to improve this repository.

---

# Happy Deploying! 🎉
