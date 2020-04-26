pipeline {
    agent {
        node {
            label 'nodejs'
        }
    }
    stages {
        stage('Restore') {
            steps {
                sh 'npm run install'
            }
        }
        stage('Build') {
            steps {
                sh 'npm run ng build'
            }
        }
        stage('Test') {
            steps {
                sh 'npm run ng test'
            }
        }        
        stage('Deploy') {
            steps {
                echo 'deploying..'
                // sh 'rm ../../apps/*'
                // sh 'cp ./dist/apps/* ../../apps/'
            }
        }             
    }
}