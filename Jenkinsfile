environment {
    APP_NAME = "java_app"
    RELEASE = "1.0.0"
    DOCKER_USER = "striver121"
    IMAGE_NAME = "my-demo-app"
    IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
    }

podTemplate(containers: [
    containerTemplate(name: 'java', image: 'eclipse-temurin:17.0.6_10-jdk', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'maven', image: 'maven:3.9.0-eclipse-temurin-17', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'trivy', image: 'aquasec/trivy:0.45.1', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker:19.03.8-dind', ttyEnabled: true, privileged: true)
  ]
/*  ,
    volumes: [
        hostPathVolume(mountPath: '/app', hostPath: '/tmp/app')
   ]
*/    ) 
{
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

        stage('Image Build') {
            container('docker') {
                 docker.withRegistry('', 'dockerhub-creds') {
                    sh 'docker build -t demoapp .'
                }
            }
        }

      
        stage('Image Push') {
            container('docker') {
                 docker.withRegistry('', 'dockerhub-creds') {
                    sh 'set +e'
                    sh '/bin/sh'
                    sh 'docker image tag demoapp striver121/demoapp:latest'
                    sh 'docker push striver121/demoapp'
                }
            }
        }

/*        stage ("wait_for_testing")
            container('docker') {
                sh 'sleep 300'
            }        
*/        
    }
  } 
