
pipeline {
  agent {
    node {
      label 'nodejs'
    }

  }
  stages {
    stage('Build') {
      steps {
        // npm --version
        // npm install
        // sh '#!/bin/sh'
        sh 'node --version'
        sh 'npm --version'
        // sh  'which node'
        // sh 'whereis node'
        // sh 'pwd'
        // sh 'cd /root/usr/bin/node'
        // sh 'pwd'
        sh 'npm install'
       

        echo 'Install completed..............'
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
        echo 'Deploying.122222222...'
      }
    }
  }
}
