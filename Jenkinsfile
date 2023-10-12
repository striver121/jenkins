pipeline
{
    agent any
    
    tools 
     {
        jdk 'Java17'
        maven 'Maven3'
     }
    
    stages
     {        
        stage("Checkout from SCM")
         {
            steps 
             { 
                git branch: 'master', credentialsId: 'github', url: 'https://github.com/striver121/jenkins.git' 
             }
         }
        stage("Sonarqube Analysis") 
         {
            steps 
             {
               script
                {
                   withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') 
                    {
                      sh "mvn sonar:sonar"
                    }
                }
             }
         }
        stage("Quality Gate") 
         {
            steps 
             {
               script
                {
                   waitForQualityGate abortPipeline: false, credentialsId: 'jenkins-sonarqube-token'
                }
             }
         }     
        stage("Build Application")
         {
            steps 
             {
                sh "mvn clean package"
             }
         }
        stage("OWASP SCAN - Dependency Scanner")
         {
            steps 
             {
               script
                {
                  dependencyCheck additionalArguments: '', odcInstallation: 'DP-check'
                  dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
             }
         }    
        stage("Test Application")
         {
            steps 
             {
                sh "mvn test"
             }       
            post
             {
                always 
                 {
                   junit '**/target/surefire-reports/TEST-*.xml'
                 }
             }
         }
      }
}
