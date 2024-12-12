def call(String imageName, String buildNumber) {
    sh """
        echo "Building image: ${imageName}:${buildNumber}"
        docker build -t ${imageName}:${buildNumber} .
    """
}
