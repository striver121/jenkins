pipeline{
    agent any
    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    stages{        
        stage("Checkout from SCM"){
            steps { 
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/striver121/jenkins.git' 
            }
        }

    }
}
