# Updating Applications and Rolling Back Changes

- Deploy NGINX with 3 replicas.
- Create a service to expose NGINX deployment and use port forwarding to access NGINX service locally.
- Update NGINX image in the deployment to Apache image.
- View deployment's rollout history.
- Roll back NGINX deployment to the previous image version and Monitor pod status to confirm successful rollback.

## Overview

This guide demonstrates how to deploy NGINX in Kubernetes, perform updates, handle rollbacks, and monitor deployment status. It covers creating a deployment with multiple replicas, exposing it via a service, and managing the deployment lifecycle.

## Table of Contents

- [Initial Deployment](#initial-deployment)
- [Service Configuration](#service-configuration)
- [Port Forwarding](#port-forwarding)
- [Updating Deployment](#updating-deployment)
- [Rollback Operations](#rollback-operations)
- [Monitoring](#monitoring)

## Initial Deployment

### NGINX Deployment YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

### Service Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

### Deploy the Application

```bash
# Apply the configuration
kubectl apply -f nginx-deployment.yaml
```

### Port Forwarding

Enable local access to the NGINX service:

```bash
# Forward local port 8080 to service port 80
kubectl port-forward service/nginx-service 8080:80
```

Access the application at:
http://localhost:8080

## Updating Deployment

### Method 1: Direct Image Update

```bash
# Update using kubectl command
kubectl set image deployment/nginx nginx=httpd:latest
```

### Method 2: YAML Update

Update the deployment YAML:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: httpd:latest
          ports:
            - containerPort: 80
```

Apply the updated configuration:

```bash
kubectl apply -f nginx-deployment.yaml
```

## Rollback Operations

### View Rollout History

```bash
# Check deployment history
kubectl rollout history deployment/nginx
```

### Perform Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/nginx
```

## Monitoring

### Check Pod Status

```bash
# List all pods
kubectl get pods

# Watch deployment status
kubectl rollout status deployment/nginx
```

## Troubleshooting

- If pods aren't starting, check logs:

```bash
kubectl logs <pod-name>
```

- For deployment issues:

```bash
kubectl describe deployment nginx
```

- Service connectivity:

```bash
kubectl describe service nginx-service
```
