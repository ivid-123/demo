pipeline {
    agent {
        node {
            label 'nodejs'
        }
    }
    stages {
        stage('Restore') {
            steps {
                sh 'npm install'
            }
        }
        stage('Build') {
            steps {
                sh 'npm build'
            }
        }
        stage('Test') {
            steps {
                sh 'ng test'
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