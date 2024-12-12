# Kubernetes Application Deployment Pipeline

This `Jenkinsfile` defines a CI/CD pipeline for building, pushing, and deploying a Dockerized application to a Kubernetes cluster running in a Kind (Kubernetes in Docker) environment. The pipeline is structured into distinct stages to ensure modularity and clarity.

## Pipeline Overview
## Prerequisites:
- Jenkins server with following plugins:
  - Docker Pipeline
  - Kubernetes CLI
  - Credentials Binding
- Docker installed on Jenkins agent
- kubectl CLI tool
- Kind (Kubernetes in Docker) installed
- Access to Docker Hub
- GitHub repository access

## Required Jenkins Credentials
1. `dockerhub-credentials`: Docker Hub credentials (Username with password)
2. `kind-kubeconfig`: Kind cluster kubeconfig file (Secret file)



### Environment Variables
The pipeline uses several environment variables to streamline configuration:
- **DOCKER_HUB_CREDENTIALS**: Jenkins credentials ID for Docker Hub.
- **DOCKER_IMAGE_NAME**: Name of the Docker image, e.g., `mujimmy/lab-app`.
- **GITHUB_REPO_URL**: URL of the GitHub repository.
- **KIND_CLUSTER_NAME**: Name of the Kind cluster.
- **KUBECONFIG_FILE**: Path to the Kubernetes configuration file.
- **KIND_HOME**: Directory for Kind configuration files.
- **KUBE_CONFIG_PATH**: Path to the Kubernetes config directory.

---

## Pipeline Stages

### 1. Validate Environment
**Purpose**: Ensure all required tools (Docker, kubectl, Kind) are installed and the Kind cluster is operational.

**Details from Jenkinsfile**:
- Check installed versions of `docker`, `kubectl`, and `kind`.
- List available clusters using `kind get clusters`.

### 2. Checkout Code
**Purpose**: Pull the source code from the Git repository.

**Details from Jenkinsfile**:
- The `checkout scm` command retrieves the current branch or commit of the repository defined in the Jenkins job configuration.

### 3. Build Docker Image
**Purpose**: Build a Docker image for the application.

**Details from Jenkinsfile**:
- The image is built using the command `docker build -t ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} .`.
- Errors during the build process are handled using a `try-catch` block to fail gracefully.

### 4. Push to Docker Hub
**Purpose**: Push the Docker image to Docker Hub for distribution.

**Details from Jenkinsfile**:
- The image is pushed using the `docker push` command for both version-specific and `latest` tags.
- Authentication is handled by `withDockerRegistry` using the `DOCKER_HUB_CREDENTIALS` variable.

### 5. Deploy to Kind Cluster
**Purpose**: Deploy the application to a Kubernetes cluster running in Kind.

**Details from Jenkinsfile**:
- The Docker image is loaded into the Kind cluster using `kind load docker-image`.
- Deployment and Service manifests are defined inline within the Jenkins pipeline and applied using `kubectl apply -f deployment.yaml`.
- Deployment readiness is ensured using `kubectl rollout status`.

### 6. Verify Kind Deployment
**Purpose**: Verify the application is running correctly in the cluster.

**Details from Jenkinsfile**:
- Pod status is checked with `kubectl get pods -l app=lab-app`.
- Logs are retrieved for each pod with `kubectl logs`.
- The service is tested with `curl -v http://localhost:30080` to ensure the application is accessible.

---

## Post Actions

### Success
**Details from Jenkinsfile**:
- Success messages display deployment status and application access URL.

### Failure
**Details from Jenkinsfile**:
- Debug information is collected, including pod descriptions and logs.

### Always
**Details from Jenkinsfile**:
- Clean-up actions include:
  - Removing unused Docker images.
  - Logging out of Docker.
  - Cleaning up the workspace with `cleanWs()`.

---

## Running the Pipeline
1. Add the necessary credentials (`dockerhub-credentials` and `kind-kubeconfig`) in Jenkins.
2. Ensure the Kind cluster is set up and accessible from the Jenkins agent.
3. Trigger the pipeline to validate the stages and deploy the application.

---

## Notes
- The NodePort service exposes the application on `http://localhost:30080`.
- If `curl` fails to connect, verify network configuration and Kind cluster accessibility.