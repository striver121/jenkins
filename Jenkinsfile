podTemplate(containers: [
    containerTemplate(name: 'openjdk', image: 'openjdk:17-jdk-slim', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'maven', image: 'maven:3.8.3-openjdk-17', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'trivy', image: 'aquasec/trivy:0.45.1', ttyEnabled: true, command: 'cat')
  ]) {

    node(POD_LABEL) {
        stage('1. Checkout from PRIVATE SCM & REPO Scanning') {
            git branch: 'master', credentialsId: 'github', url: 'https://github.com/striver121/jenkins.git'
                container('trivy') {
                    stage('Scan Remote') {
                        sh 'trivy filesystem . --ignore-unfixed --exit-code 0'
                        sh 'trivy plugin install github.com/aquasecurity/trivy-plugin-kubectl'
                    }
                }
        }    

        stage('SONARQUBE ANALYSIS') {
            container('maven') {
                withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('QUALITY GATES') {
            container('maven') {
                timeout(time:1, unit: 'HOURS') {
                    waitForQualityGate(abortPipeline: 'false', credentialsId: 'jenkins-sonarqube-token')
                }
            }
        }    

        stage('MAVEN BUILD TARGET') {
            container('maven') {
                stage('Build a Maven project') {
                    sh 'mvn clean package'
                }
            }
        }
        
        
        stage('Test Application') {
            container('maven') {
                stage('Test Maven Built Application') {
                    sh 'mvn test'
                }
            }
        }   
        
         stage('JUNIT Test Reports') {
            container('maven') {
                stage('Looking the Workspace target directory for XML reports') {
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
            }
        }        
        
    }
  } 
