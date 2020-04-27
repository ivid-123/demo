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
        EXECUTE_TAG_STAGE = "true"
        EXECUTE_BUILD_STAGE = "true"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                // required to run unit test using phontonjs 
                //sh 'npm install chrome -g'
                //sh 'which chrome'
                //sh 'npm install phantomjs-prebuilt -g --ddd'
                //sh 'npm install phantomjs-prebuilt@2.1.14 --ignore-scripts'
                //sh 'which chrome'
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
                        /// sh 'npm run prettier:check'
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
                            sh 'npm run test:phantom'
                        }
                    }
                }
            }
        }
        // stage('Build Image') {
        //     steps {
        //         //sh 'bash ./src/jenkins/scripts/build.sh'
        //         sh 'npm build --prod'
        //         echo 'a versioned package for your the artifacts repository'
        //     }
        // }
        // ------------------------------------
        // -- STAGE: build
        // ------------------------------------
        stage('build') {
            when {
                environment name: "EXECUTE_BUILD_STAGE", value: "true"
            }

            steps{
                script{
                    echo 'Build Stage - Creating builder image'
                    openshiftBuild(
                        bldCfg: "${SPA_NAME}-builder",
                        showBuildLogs: "true",
                        verbose: "true",
                        waitTime: "1800000"
                    )

                    echo 'Build Stage - Creating runtime image'
                    openshiftBuild(
                        bldCfg: "${SPA_NAME}-runtime",
                        showBuildLogs: "true",
                        verbose: "true"
                    )

                    currentBuild.result = 'SUCCESS'
                }
            }
        }
        // ------------------------------------
        // -- STAGE: tag
        // ------------------------------------
        stage('tag') {
            when {
                environment name: "EXECUTE_TAG_STAGE", value: "true"
            }

            steps{
                script{
                    echo 'Tag Stage - Tagging current image'
                    openshiftTag(
                        srcStream: "${SPA_NAME}-builder",
                        srcTag: "latest",
                        destStream: "${SPA_NAME}-builder",
                        destTag: "${DEV_TAG}",
                        verbose: "true"
                    )

                    currentBuild.result = 'SUCCESS'
                }
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