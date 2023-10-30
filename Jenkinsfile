environment {
    def APP_NAME = "demoapp"
    def DOCKER_USER = "striver121"
    }

podTemplate(containers: [
    containerTemplate(name: 'java', image: 'eclipse-temurin:17.0.6_10-jdk', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'maven', image: 'maven:3.9.0-eclipse-temurin-17', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'trivy', image: 'aquasec/trivy:0.45.1', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker:20.10.16-dind', ttyEnabled: true, privileged: true)
  ]) {
    node(POD_LABEL) {
        
            stage ("1. Pulling Repository to Jenkins Workspace + Vulnerability Scanning") {
                git branch: 'master', credentialsId: 'github', url: 'https://github.com/striver121/jenkins.git'
                    stage ("1.1: Trivy Local Repo Scanning for Vulnerability")
                        container('trivy') {
                            sh 'trivy filesystem . --no-progress --ignore-unfixed --exit-code 0 --severity CRITICAL'
                            sh 'trivy plugin install github.com/aquasecurity/trivy-plugin-kubectl'
                        }
            } 
            
            stage('2. Sonarqube Code Analysis') {
                stage ("2.1: SONARQUBE Analysis")
                    container('maven') {
                        withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') {
                            sh 'mvn sonar:sonar'
                        }    
                    }      
                    
                stage ("2.2: QUALITY GATES")
                    container('maven') {
                        timeout(time:3, unit: 'HOURS') {
                            waitForQualityGate(abortPipeline: 'true', credentialsId: 'jenkins-sonarqube-token')
                        }    
                    }
                    
                stage ("2.3: Building Project Dependencies")
                    container('maven') {
                        sh 'mvn dependency:copy-dependencies'
                    }
                    
                stage ("2.4: OWASP SBOM - Scanning Vulnabilities on Project's Dependencies")
                    container('maven') {
                        dependencyCheck additionalArguments: '--cveStartYear 2023 --failOnCVSS 8 --scan target/dependency/*.jar --format HTML --prettyPrint', odcInstallation: 'dep-chk'
                    }                    
            }
 
            stage('3. Building the App Code & Perform the Test') {
                stage ("3.1: Buil a Maven Project")
                    container('maven') {
                        sh 'mvn clean package war:war'
                    }
                    
                stage ("3.2: Test Maven Built Application")
                    container('maven') {
                        sh 'mvn test'
                    }
            }
            
            stage('4. Build Image & Perform Vulnerability Scanning on Image') {
                stage ("4.1: Building Docker Image")
                    container('docker') {
                        docker.withRegistry('', 'dockerhub-creds') {
                            sh 'docker build -t demoapp .'
                        }
                    }    
                    
                stage ("4.2: Performing Trivy Vulnerability Scanning on Image")
                    container('docker') {
                            sh ('docker run -v /var/run/docker.sock:/var/run/docker.sock -v ${WORKSPACE}:${WORKSPACE} aquasec/trivy image --no-progress --scanners vuln  --exit-code 0 --severity CRITICAL --format template --template "@/contrib/html.tpl" -o ${WORKSPACE}/trivy_report.html demoapp:latest')
                            /*sh ('docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image demoapp:latest --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table')*/
                    }
            }
    
            stage('5. Uploading Artifacts to Repository') {
                stage ("5.1: Pushing Artifacts to Nexus")
                    container('jnlp') {
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
                    
                stage('Pushing the Docker Image to Image Registery') {
                    container('docker') {
                        docker.withRegistry('', 'dockerhub-creds') {
                            sh 'docker image tag demoapp striver121/demoapp:v.0.${BUILD_ID}'
                            sh 'docker push striver121/demoapp:v.0.${BUILD_ID}'
                        }
                    }
                }    
            
            }
            
            stage ('6. Generating Reports') {
                stage ('6.1: JUNIT Testing Report')
                    container('maven') {
                    /*    archiveArtifacts artifacts: 'target/dependency/*.jar', fingerprint: true */
                        junit '**/target/surefire-reports/TEST-*.xml'
                }
            
                stage('6.2: Dependency-Check Results publishing to viewable HTML Reports')
                    container('jnlp') {
                        publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: '', reportFiles: 'dependency-*.html', reportName: 'Dependency-Check-Report', reportTitles: 'SBOM', useWrapperFileDirectly: true])
                    }
                
                stage('6.3: Trivy Image Scan Results publishing to viewable HTML Reports')
                    archiveArtifacts artifacts: "trivy_report.html", fingerprint: true
                    container('jnlp') {
                        publishHTML (target: [
                            allowMissing: false,
                            alwaysLinkToLastBuild: false,
                            keepAll: true,
                            reportDir: '.',
                            reportFiles: 'trivy_report.html',
                            reportName: 'Trivy Scan',
                            ])
                    }                
                
            }            

/* DEBUG
            stage ("tree")
                 container('trivy') {
                      sh 'tree'
                }
            stage ("sleep")
                 container('trivy') {
                      sh 'sleep 30000'
                }   
            stage ("env")
                 container('jnlp') {
                      sh 'printenv'
                }                               
*/        
    }
  } 
