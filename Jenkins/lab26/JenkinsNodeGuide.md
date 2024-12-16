# Jenkins Slave Node Setup Guide

This guide provides detailed instructions for setting up a Jenkins slave node to work with pipelines that require specific node labeling. The setup ensures proper execution of Docker and Kubernetes operations.

## Table of Contents
- [Prerequisites](#prerequisites)
- [System Requirements](#system-requirements)
- [Detailed Setup Steps](#detailed-setup-steps)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)

## Prerequisites

### On Master Node
- Jenkins master server installed and running
- Administrative access to Jenkins
- Network connectivity between master and slave

### On Slave Node
- Ubuntu/Debian-based system (recommended)
- Root or sudo access
- Minimum 2GB RAM
- 20GB disk space
- Network connectivity

## System Requirements

Required software on slave node:
- Java JDK 11 or higher
- Docker
- Git
- kubectl
- SSH server

## Detailed Setup Steps

### 1. Prepare the Slave Machine

```bash
# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Java
sudo apt install openjdk-11-jdk -y

# Verify Java installation
java -version

# Install Docker
sudo apt install docker.io -y

# Create Jenkins user
sudo useradd -m -s /bin/bash jenkins

# Set password for Jenkins user
sudo passwd jenkins

# Add Jenkins user to Docker group
sudo usermod -aG docker jenkins

# Create workspace directory
sudo mkdir -p /home/jenkins/workspace
sudo chown -R jenkins:jenkins /home/jenkins/workspace

```
### 2. Configure SSH Access

```bash
# Switch to Jenkins user
sudo su - jenkins

# Generate SSH key pair
ssh-keygen -t rsa -b 4096
# Press Enter for default location
# Press Enter twice for empty passphrase

# Display public key (copy this for later use)
cat ~/.ssh/id_rsa.pub

```
### 3. Jenkins Master Configuration

3.1 Access Jenkins Dashboard

    - Open web browser

    - Navigate to Jenkins URL

    - Login with admin credentials

3.2 Add New Node

    - Go to "Manage Jenkins"

    - Select "Manage Nodes and Clouds"

    - Click "New Node"

3.3 Configure Node Settings

    Node name: jenkins-slave
    Type: [x] Permanent Agent

3.4 Configure Node Details
```bash
# Basic Settings
Name: jenkins-slave
Description: Jenkins slave node for Docker builds
Number of executors: 2
Remote root directory: /home/jenkins/workspace
Labels: jenkins-slave
Usage: Use this node as much as possible

# Launch method
Launch method: Launch agents via SSH
Host: [Your slave machine IP]
Credentials: Add → Jenkins

```
3.5 Add SSH Credentials
```bash
Kind: SSH Username with private key
ID: jenkins-slave-ssh
Description: Jenkins Slave SSH
Username: jenkins
Private Key: [Enter directly]
# Paste the private key content here

```
### 4. Install Required Tools
```bash
# Install Git
sudo apt install git -y

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installations
git --version
docker --version
kubectl version --client
```
### 5. Verify Node Connection
    1- On Jenkins dashboard:

        Click on the newly created node

        Check status (should show "Agent successfully connected")

    2- Run test pipeline:
```bash
pipeline {
    agent {
        node {
            label 'jenkins-slave'
        }
    }
    stages {
        stage('Test') {
            steps {
                sh 'echo "Node is working"'
            }
        }
    }
}

```

### Troubleshooting

    Common Issues and Solutions
        1- Connection Failed
```bash
# Check SSH service
sudo systemctl status sshd

# Verify connectivity
ssh jenkins@slave-ip

# Check firewall
sudo ufw status
```
        2- Permission Issues
```bash
# Fix workspace permissions
sudo chown -R jenkins:jenkins /home/jenkins/workspace

# Fix Docker permissions
sudo chmod 666 /var/run/docker.sock
```
        3- Node Offline
```bash
# Check Jenkins slave process
ps aux | grep jenkins

# Check logs
tail -f /var/log/jenkins/jenkins.log
```

### Maintenance

    1- Docker Cleanup
```bash
# Remove unused images and containers
docker system prune -af
```
    2- Disk Space Management
```bash
# Check disk usage
df -h

# Clean workspace
cd /home/jenkins/workspace
rm -rf */
```

### Using the Node in Pipeline
```bash
pipeline {
    agent {
        node {
            label 'jenkins-slave'
        }
    }
    // rest of your pipeline
}






