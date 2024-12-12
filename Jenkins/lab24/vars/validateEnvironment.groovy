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
