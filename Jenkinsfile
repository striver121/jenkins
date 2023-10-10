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
     
        stage("Build Application")
         {
            steps 
             {
                sh "mvn clean package"
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
