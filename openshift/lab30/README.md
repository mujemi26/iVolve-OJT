# Kubernetes Security and RBAC Guide 🔐

This guide demonstrates how to implement Role-Based Access Control (RBAC) in Kubernetes, including creating Service Accounts, Roles, and RoleBindings.

## Table of Contents 📑

- [Prerequisites](#prerequisites)
- [Service Account Creation](#service-account-creation)
- [Service Account Token](#service-account-token)
- [Role Configuration](#role-configuration)
- [Role Binding Setup](#role-binding-setup)
- [Token Retrieval](#token-retrieval)

## Prerequisites 📋

- Access to a Kubernetes cluster

- kubectl CLI tool installed

- Appropriate permissions to create RBAC resources

## Service Account Creation 👤

Service Accounts authenticate processes running inside a Kubernetes cluster.

```bash
# Create a Service Account
kubectl create serviceaccount jimmy-serviceaccount

# Verify creation
kubectl get serviceaccount jimmy-serviceaccount
```

## Service Account Token 🔑

Create a Service Account token using the following configuration:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: jimmy-serviceaccount-token
  namespace: jimmy
  annotations:
    kubernetes.io/service-account.name: "jimmy-serviceaccount"
type: kubernetes.io/service-account-token
```

```bash
# Apply the configuration
kubectl apply -f jimmy-token.yaml
```

## Role Configuration ⚙️

Create a pod-reader Role for read-only access to pods:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
```

```bash
# Apply the Role
kubectl apply -f pod-reader-role.yaml

# Verify Role creation
kubectl get role pod-reader -n default
```

## Role Binding Setup 🔗

Bind the Role to the Service Account:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: my-serviceaccount
    namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
# Apply the RoleBinding
kubectl apply -f role-binding.yaml

# Verify RoleBinding
kubectl get rolebinding pod-reader-binding -n default
```

## Token Retrieval 🎟️

Retrieve the Service Account token:

```bash
# Get the secret
kubectl get secret -n default | grep my-serviceaccount

# Decode the token
kubectl describe secret jimmy-serviceaccount-token -n jimmy
```

# Kubernetes RBAC Components Comparison

## Service Account vs Roles vs ClusterRoles

| Component          | Scope           | Purpose                                                      | Characteristics                                                                                                                        |
| ------------------ | --------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| Service Account    | Namespace-bound | Provides an identity for processes running in pods           | - Automatically mounted to pods<br>- Used for authentication<br>- Each namespace has a default service account                         |
| Role               | Namespace-bound | Defines permissions within a specific namespace              | - Contains rules for resources<br>- Cannot grant permissions across namespaces<br>- Used for namespace-specific access control         |
| RoleBinding        | Namespace-bound | Links Roles to subjects (users, groups, or service accounts) | - Associates subjects with roles<br>- Only affects the namespace it's created in<br>- Can reference roles only from the same namespace |
| ClusterRole        | Cluster-wide    | Defines permissions across entire cluster                    | - Not limited to a specific namespace<br>- Can define access for cluster-wide resources<br>- Can be used for multiple namespaces       |
| ClusterRoleBinding | Cluster-wide    | Links ClusterRoles to subjects across all namespaces         | - Grants permissions cluster-wide<br>- Can reference any service account from any namespace<br>- Affects all namespaces in the cluster |

## Key Differences

### Role vs ClusterRole

- **Roles** are namespace-scoped and can only be used to grant access to resources within a specific namespace
- **ClusterRoles** are cluster-scoped and can be used to grant access to:
  - cluster-scoped resources (like nodes)
  - non-resource endpoints (like `/healthz`)
  - resources across all namespaces

### RoleBinding vs ClusterRoleBinding

- **RoleBinding** grants permissions within a specific namespace
- **ClusterRoleBinding** grants permissions across the entire cluster
- Both can reference a ClusterRole, but RoleBinding will only apply those permissions within its namespace

### Common Use Cases

1. **Namespace-Level Access**

   - Use: Role + RoleBinding
   - Example: Giving a service account read access to pods in a specific namespace

2. **Cluster-Level Access**

   - Use: ClusterRole + ClusterRoleBinding
   - Example: Giving a service account ability to manage nodes or persistent volumes

3. **Reusing ClusterRoles**
   - Use: ClusterRole + RoleBinding
   - Example: Using a ClusterRole for common permissions but limiting them to specific namespaces

## Best Practices

1. Follow the principle of least privilege
2. Use namespace-scoped roles when possible
3. Create custom roles instead of using default cluster-admin
4. Regularly audit RBAC configurations
5. Use groups for role bindings when managing multiple users
