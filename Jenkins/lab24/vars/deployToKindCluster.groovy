def call(String imageName, String buildNumber, String kubeConfig, String clusterName) {
    withCredentials([file(credentialsId: kubeConfig, variable: 'KUBECONFIG_FILE')]) {
        sh """
            export KUBECONFIG=${KUBECONFIG_FILE}
            kind load docker-image ${imageName}:${buildNumber} --name ${clusterName}

            cat > deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-app-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: lab-app
  template:
    metadata:
      labels:
        app: lab-app
    spec:
      containers:
      - name: lab-app
        image: ${imageName}:${buildNumber}
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: lab-app-service
spec:
  type: NodePort
  selector:
    app: lab-app
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
EOF

            kubectl apply -f deployment.yaml
            kubectl rollout status deployment/lab-app-deployment --timeout=300s
        """
    }
}
