# Kubernetes Deployment vs StatefulSet

## Overview

This guide explains the key differences between Kubernetes Deployments and StatefulSets, helping you choose the right resource for your applications.

## Quick Comparison Table

| Feature          | Deployment                    | StatefulSet                   |
| ---------------- | ----------------------------- | ----------------------------- |
| State Management | Stateless                     | Stateful                      |
| Pod Identity     | Random names                  | Predictable, persistent names |
| Storage          | Usually no persistent storage | Persistent storage per Pod    |
| Scaling Order    | Random                        | Sequential (ordered)          |
| Network Identity | Dynamic                       | Stable, persistent            |
| Use Case         | Web servers, APIs             | Databases, Message brokers    |

## Deployment

### What is a Deployment?

A Deployment manages stateless applications where each Pod is interchangeable and disposable.

### Key Features

1. **Interchangeable Pods**

   - Random Pod names (e.g., nginx-7849d9b86f-x2v5l)
   - Any Pod can be replaced without impact

2. **No Persistent Storage Required**

   - Data typically stored externally
   - Pods are ephemeral

3. **Flexible Scaling**
   - Scale up/down in any order
   - Immediate bulk scaling possible

### Ideal Use Cases

- Web servers (NGINX, Apache)
- Stateless microservices
- API servers
- Static content servers

## StatefulSet

### What is a StatefulSet?

A StatefulSet manages stateful applications requiring stable network identity and persistent storage.

### Key Features

1. **Unique Pod Identity**

   - Predictable Pod names (e.g., mysql-0, mysql-1)
   - Identity persists across rescheduling

2. **Persistent Storage**

   - Dedicated storage per Pod
   - Storage remains even if Pod dies

3. **Ordered Operations**

   - Sequential Pod creation (0,1,2...)
   - Reverse order deletion (2,1,0)

4. **Stable Networking**
   - Persistent DNS names
   - Predictable hostnames

### Ideal Use Cases

- Databases (MySQL, PostgreSQL)
- Message brokers (Kafka)
- Distributed systems (ZooKeeper)
- Clustered applications

## Example Scenarios

### Deployment Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
```

### StatefulSet Example

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:5.7
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi
```

### When to Choose Which?

Choose Deployment when:

    - Your application is stateless

    - Pods are interchangeable

    - You need rapid scaling

    - No persistent data storage needed

Choose StatefulSet when:

    - Your application needs persistent storage

    - Stable network identifiers required

    - Ordered deployment/scaling is important

    - You need predictable Pod names

## Understanding Kubernetes Services

Kubernetes Services provide networking and load balancing for a set of Pods. There are two main types of services relevant to our discussion:

### 1. Normal Service

- Provides a single IP address (ClusterIP)
- Load balances traffic across all Pods
- Ideal for stateless applications
- Example DNS: `mysql-service`

Example Normal Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  labels:
    app: mysql
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
```

### 2. Headless Service

    - Has clusterIP: None

    - Creates individual DNS entries for each Pod

    - Essential for StatefulSets

    - Example DNS: mysql-0.mysql-headless

Example Headless Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
  labels:
    app: mysql
spec:
  clusterIP: None # This makes it headless
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
```

## Complete MySQL StatefulSet YAML

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  serviceName: "mysql-headless"
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: rootpassword
            - name: MYSQL_DATABASE
              value: mydb
            - name: MYSQL_USER
              value: user
            - name: MYSQL_PASSWORD
              value: userpassword
          ports:
            - containerPort: 3306
              name: mysql
          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: mysql-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi
```

## Deployment Steps

    1. Create Headless Service

```bash
kubectl apply -f mysql-headless-service.yaml
```

    2. Deploy StatefulSet

```bash
kubectl apply -f mysql-statefulset.yaml
```

    3. Verify Deployment

```bash
# Check StatefulSet
kubectl get statefulsets

# Check Pods
kubectl get pods -l app=mysql

# Check Services
kubectl get services
```

## Common Use Cases

    - Primary-Secondary database setups

    - Distributed databases

    - Applications requiring stable network identities
