environment {
    def APP_NAME = "java_app"
    def RELEASE = "1.0.0"
    def DOCKER_USER = "striver121"
    def IMAGE_NAME = "my-demo-app"
    def IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }

podTemplate(containers: [
    containerTemplate(name: 'java', image: 'eclipse-temurin:17.0.6_10-jdk', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'maven', image: 'maven:3.9.0-eclipse-temurin-17', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'trivy', image: 'aquasec/trivy:0.45.1', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker:20.10.16-dind', ttyEnabled: true, privileged: true)
  ]
  /*,
    volumes: [
        hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker')
        hostPathVolume(mountPath: '/var/run/docker.sock')', hostPath: '/var/run/docker.sock')
        hostPathVolume(mountPath: '/app', hostPath: '/tmp/app')
   ]*/
) 
{
    node(POD_LABEL) {
/*        stage ("print vars")
            container('trivy') {
                sh 'printenv'
            } 
*/            
        stage('Checkout from PRIVATE SCM & REPO Scanning') {
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
                    sh 'mvn clean package war:war'
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

        stage('Scanning IMAGE for Security') {
                container('docker') {
                    stage('Scan Image') {
                        sh ('docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image demoapp:latest --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table')
                    }
                }
        }

        stage('Upload Artifacts to Nexus') {
            container('jnlp') {
                stage('Looking the Workspace target directory for WAR file Packaging files') {
                    nexusArtifactUploader artifacts: [
                        [
                        artifactId: 'spring-boot-starter-parent', 
                        classifier: '', 
                        file: 'target/demoapp-1.0.0.war', 
                        type: 'war'
                        ]
                    ], 
                    credentialsId: 'nexus-jenkins', 
                    groupId: 'com.dmancloud.dinesh', 
                    nexusUrl: 'nexus-nexus-repository-manager.nexus.svc.cluster.local:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: 'demo-app', 
                    version: '1.0.0'                    
                }
            }
        }
        
        stage('Image Push') {
            container('docker') {
                 docker.withRegistry('', 'dockerhub-creds') {
                    sh 'set +e'
/*                    sh '/bin/sh' */
                    sh 'docker image tag demoapp striver121/demoapp:latest'
                    sh 'docker push striver121/demoapp:latest'
                }
            }
        }

     /*   stage ("wait_for_testing")
            container('docker') {
                sh 'sleep 3000'
            }        
     */   
    }
  } 
