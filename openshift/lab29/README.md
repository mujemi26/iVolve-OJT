# Kubernetes Storage Configuration Demo 🚀

This guide demonstrates how to configure persistent storage in Kubernetes using NGINX as an example application.

# Table of Contents 📑

- [Prerequisites](#prerequisites)
- [Overview](#overview)
- [Step-by-Step Guide](#step-by-step-guide)
  - [Creating the Initial Deployment](#creating-the-initial-deployment)
  - [Testing File Creation and Access](#testing-file-creation-and-access)
  - [Testing Storage Persistence](#testing-storage-persistence)
  - [Implementing Persistent Storage](#implementing-persistent-storage)
  - [Verifying Persistent Storage](#verifying-persistent-storage)
- [Storage Concepts Comparison](#storage-concepts-comparison)

# Prerequisites

- Kubernetes cluster

- kubectl CLI tool

- Basic understanding of Kubernetes concepts

# Overview

This demo shows how to:

- Deploy an NGINX application

- Work with different storage types

- Understand storage persistence behavior

- Implement persistent storage using PVC

# Step-by-Step Guide

## 1. Creating the Initial Deployment 🏗️

Create a file named nginx-deployment.yaml:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 1
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
          volumeMounts:
            - name: html-data
              mountPath: /usr/share/nginx/html
      volumes:
        - name: html-data
          emptyDir: {}
```

## 2. Testing File Creation and Access 📝

```bash
# Deploy the application
kubectl apply -f nginx-deployment.yaml

# Verify deployment
kubectl get pods

# Access the pod
kubectl exec -it <nginx-pod-name> -- /bin/bash

# Create test file
echo "hello, this is <your-name>" > /usr/share/nginx/html/hello.txt

# Test file access
kubectl port-forward <nginx-pod-name> 8080:80
curl localhost:8080/hello.txt
```

## 3. Testing Storage Persistence 🔄

```bash
# Delete the pod
kubectl delete pod <nginx-pod-name>

# Verify new pod creation
kubectl get pods

# Check if file exists in new pod
kubectl exec -it <new-nginx-pod-name> -- cat /usr/share/nginx/html/hello.txt
```

## 4. Implementing Persistent Storage 💾

Create pvc.yaml:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Update deployment to use PVC:

```yaml
# Update volumes section in nginx-deployment.yaml
volumes:
  - name: html-data
    persistentVolumeClaim:
      claimName: nginx-pvc
```

## 5. Verifying Persistent Storage ✅

```bash
# Apply PVC and updated deployment
kubectl apply -f pvc.yaml
kubectl apply -f nginx-deployment.yaml

# Repeat file creation and pod deletion tests
```

# Storage Concepts Comparison

| Feature        | Persistent Volume (PV)                                            | Persistent Volume Claim (PVC)                   | Storage Class                                |
| -------------- | ----------------------------------------------------------------- | ----------------------------------------------- | -------------------------------------------- |
| **Definition** | A piece of storage in the cluster provisioned by an administrator | A request for storage by a user                 | A way to define different classes of storage |
| **Purpose**    | Defines the actual storage resource                               | Requests a specific amount of storage           | Enables dynamic storage provisioning         |
| **Lifecycle**  | Exists independently of pods                                      | Bound to a specific pod                         | Exists at cluster level                      |
| **Creation**   | Manual or dynamic via StorageClass                                | Created by users/applications                   | Created by cluster administrators            |
| **Scope**      | Cluster-wide resource                                             | Namespace-specific                              | Cluster-wide resource                        |
| **Binding**    | Can be pre-bound to specific PVC                                  | Binds to available PV matching its requirements | N/A                                          |
| **Parameters** | Capacity, Access Modes, Storage Type                              | Storage size, Access Modes                      | Provisioner, Parameters, Reclaim Policy      |
| **Deletion**   | Persists after PVC deletion                                       | Can be deleted when pod is removed              | Persists until manually deleted              |
| **Use Case**   | Providing actual storage resources                                | Requesting storage for applications             | Defining storage types and provisioning      |

## Example Configurations

### Persistent Volume (PV)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-example
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
```

### Persistent Volume Claim (PVC)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-example
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### Storage Class

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
```

## Key Relationships:

- PV ↔ PVC : PVCs bind to PVs that match their requirements (size, access mode)

- StorageClass ↔ PV : StorageClasses can dynamically provision PVs when needed

- PVC ↔ StorageClass : PVCs can request storage from a specific StorageClass

## Common Usage Pattern:

1.Admin creates StorageClass (or uses default)

2.User creates PVC requesting storage

3.StorageClass dynamically provisions PV

4.PVC binds to PV

5.Pod uses the PVC for storage
