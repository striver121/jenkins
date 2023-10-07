pipeline{
    agent{
        label "jenkins-jenkins-agent"
    }
    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    stages{        
        stage("Checkout from SCM"){
            steps { 
                git branch: 'main', credentialsId: 'git_token', url: 'https://github.com/striver121/jenkins.git' 
            }
        }

    }
}
