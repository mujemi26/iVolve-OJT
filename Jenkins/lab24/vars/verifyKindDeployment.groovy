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
