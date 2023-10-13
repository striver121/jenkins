pipeline {
    agent none
    stages {
        stage('Back-end') {
            agent { any
                       { image 'maven:3.9.4-eclipse-temurin-17-alpine' }
                  }
            steps {
                sh 'mvn --version'
            }
        }
    }
}
