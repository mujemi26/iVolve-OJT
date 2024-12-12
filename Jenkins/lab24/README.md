<h1>Jenkins Shared Libraries</h1>

<pre style="font-size: 19px">
Objective: 
        - Implement shared libraries in Jenkins to reuse code across multiple pipelines.
        - Create a shared library for common tasks and demonstrate its usage in different pipelines.
</pre>

# Step 1: Create a Shared Library

```
# Set up a Git repository for the shared library with the following structure:

(root)
└── vars
    ├── validateEnvironment.groovy
    ├── checkoutCode.groovy
    ├── buildDockerImage.groovy
    ├── pushToDockerHub.groovy
    ├── deployToKindCluster.groovy
    └── verifyKindDeployment.groovy

```
> ## 1. validateEnvironment.groovy

```
def call() {
    sh '''
        echo "Checking required tools..."
        docker version
        kubectl version --client
        kind version

        echo "Checking cluster status..."
        kind get clusters
    '''
}

```
> ## 2. checkoutCode.groovy

```
def call() {
    checkout scm
}

```

> ## 3. buildDockerImage.groovy

```
def call(String imageName, String buildNumber) {
    sh """
        echo "Building image: ${imageName}:${buildNumber}"
        docker build -t ${imageName}:${buildNumber} .
    """
}

```

> ## 4. pushToDockerHub.groovy

```
def call(String imageName, String buildNumber, String credentialsId) {
    withDockerRegistry([credentialsId: credentialsId]) {
        sh """
            echo "Pushing images to Docker Hub..."
            docker push ${imageName}:${buildNumber}
            docker tag ${imageName}:${buildNumber} ${imageName}:latest
            docker push ${imageName}:latest
        """
    }
}

```

> ## 5. deployToKindCluster.groovy

```
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

```

> ## 6. verifyKindDeployment.groovy

```
def call(String kubeConfig) {
    withCredentials([file(credentialsId: kubeConfig, variable: 'KUBECONFIG_FILE')]) {
        sh """
            export KUBECONFIG=${KUBECONFIG_FILE}
            kubectl get pods -l app=lab-app
            for pod in \$(kubectl get pods -l app=lab-app -o name); do
                kubectl logs \$pod
            done
            kubectl get service lab-app-service
            curl -v http://localhost:30080 || true
        """
    }
}

```
# Step 2: Configure Jenkins for Shared Libraries:

```
Go to Manage Jenkins → System.
Under Global Trusted Pipeline Libraries , add:

    Name: jenkins-shared-library
    Default version: main <or the branch name>
    Retrieval method: Git
    Repository URL: https://github.com/mujemi26/jenkins-shared-library <URL of the shared library repo>
```

# Step 3: Refactor Jenkinsfile to Use Shared Library:

```
# Adjust your Jenkinsfile to call the shared library functions:


@Library('jenkins-shared-library') _

pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKER_IMAGE_NAME = 'mujimmy/lab-app'
        KIND_CLUSTER_NAME = 'kind-kind'
        KUBECONFIG_FILE = 'kind-kubeconfig'
    }

    stages {
        stage('Validate Environment') {
            steps {
                validateEnvironment()
            }
        }

        stage('Checkout Code') {
            steps {
                checkoutCode()
            }
        }

        stage('Build Docker Image') {
            steps {
                buildDockerImage(DOCKER_IMAGE_NAME, env.BUILD_NUMBER)
            }
        }

        stage('Push to Docker Hub') {
            steps {
                pushToDockerHub(DOCKER_IMAGE_NAME, env.BUILD_NUMBER, DOCKER_HUB_CREDENTIALS)
            }
        }

        stage('Deploy to Kind Cluster') {
            steps {
                deployToKindCluster(DOCKER_IMAGE_NAME, env.BUILD_NUMBER, KUBECONFIG_FILE, KIND_CLUSTER_NAME)
            }
        }

        stage('Verify Kind Deployment') {
            steps {
                verifyKindDeployment(KUBECONFIG_FILE)
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

```

> # Conclusion:

<pre style="font-size: 19px"> This structure keeps your pipeline DRY (Don't Repeat Yourself) and ensures scalability by centralizing the logic into reusable functions.</pre>