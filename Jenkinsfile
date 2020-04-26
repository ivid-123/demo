pipeline {
    agent {
        node {
            label 'nodejs'
        }
    }
    environment {
        SPA_NAME = "demo"
        EXECUTE_VALIDATION_STAGE = "true"
        EXECUTE_VALID_PRETTIER_STAGE = "true"
        EXECUTE_VALID_TSLINT_STAGE = "true"
        EXECUTE_TEST_STAGE = "true"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage('validation'){
            when {
                environment name: "EXECUTE_VALIDATION_STAGE", value: "true"
            }

            failFast true
            parallel {
                stage('Prettier'){
                    when {
                        environment name: "EXECUTE_VALID_PRETTIER_STAGE", value: "true"
                    }
                    steps{
                        echo 'Validation Stage - prettier'
                        //sh 'npm run prettier:check'
                    }
                }
                stage('Tslint'){
                    when {
                        environment name: "EXECUTE_VALID_TSLINT_STAGE", value: "true"
                    }
                    steps{
                        echo 'Valildation Stage - tslint'
                        sh 'npm run lint'
                    }
                }
                stage('test'){
                    when {
                        environment name: "EXECUTE_TEST_STAGE", value: "true"
                    }
                    steps{
                        script{
                            echo 'Test Stage - Launching unit tests'
                            sh 'npm run test'
                        }
                    }
                }
            }
        }
        stage('Build Image') {
            steps {
                //sh 'bash ./src/jenkins/scripts/build.sh'
                sh 'npm build --prod'
                echo 'a versioned package for your the artifacts repository'
            }
        }
        stage('Tag') {
            steps {
                echo 'apply configuration of specific enviorment and does versioning of build images then made it available for the artifacts repository'
            }
        }
        stage('Deploy on Dev') {
            when {
                branch 'development'
            }
            steps {
                sh 'bash ./src/jenkins/scripts/deliver-for-development.sh'
            }
        }
        stage('Integration Testing') {
            when {
                branch 'stage'
            }
            steps {
                echo 'run end to end tests.'
            }
        }
        stage('Deploy on Stage') {
            when {
                branch 'stage'
            }
            steps {
                sh 'bash ./src/jenkins/scripts/deploy-for-production.sh'
                input message: 'Finished using the web site? (Click "Proceed" to continue)'
                sh 'bash ./src/jenkins/scripts/kill.sh'

            }
        }
        stage('Deploy for production') {
            when {
                branch 'production'
            }
            steps {
                sh 'bash ./src/jenkins/scripts/deploy-for-production.sh'
                input message: 'Finished using the web site? (Click "Proceed" to continue)'
                sh 'bash ./src/jenkins/scripts/kill.sh'
            }
        }
        
    }
    post {
        always {
            step([$class: 'Mailer',
                notifyEveryUnstableBuild: true,
                recipients: "ashish.mishra2@soprasteria.com",
                sendToIndividuals: true])
        }
    }
}