pipeline {
    agent {
         node { 
             label 'nodejs' 
         }
    } 

    stages {
        stage('Build') {
           
            steps {
                echo 'Building..............changed again new changes again'
                echo 'Waiting 5 minutes for deployment to complete prior starting smoke testing'
                echo 'New pull request changes'
                sh 'node --version'
                sh 'npm --version'
                sh 'npm install'
                echo 'Install completed.................'
                sh 'npm run build'
                echo 'Build completed'

                sh 'npm run lint'
                echo 'Lint completed'
                sh 'npm run test'
                echo 'Test completed'
               
                
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}