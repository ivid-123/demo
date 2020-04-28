
def templatePath = 'https://raw.githubusercontent.com/openshift/nodejs-ex/master/openshift/templates/nodejs-mongodb.json'
def templateName = 'nodejs-mongodb-example'

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
        stage('preamble') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            echo "Using project: ${openshift.project()}"
                        }
                    }
                }
            }
        }
        stage('cleanup') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            openshift.selector("all", [template : templateName]).delete()
                            if (openshift.selector("secrets", templateName).exists()) {
                                openshift.selector("secrets", templateName).delete()
                            }
                        }
                    }
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                // required to run unit test using phontonjs 
                //sh 'npm install chrome -g'
                //sh 'which chrome'
                //sh 'npm install phantomjs-prebuilt -g --ddd'
                //sh 'npm install phantomjs-prebuilt@2.1.14 --ignore-scripts'
                // sh 'which chrome'
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

        

        stage('Create Image Builder') {

            // when {

            //     expression {

            //         openshift.withCluster() {

            //             return !openshift.selector("bc", "sample-pipeline").exists();

            //         }

            //     }

            // }

            steps {

                script {

                    openshift.withCluster() {

                        //openshift.newBuild("--name=sample-pipeline", "--image-stream=redhat-openjdk18-openshift:1.1", "--binary")
                        openshiftBuild bldCfg: 'sample-pipeline'

                    }

                }

            }

        }

        stage('Build Image') {

            steps {

                script {

                    openshift.withCluster() {

                        openshift.selector("bc", "mapit").startBuild("--from-file=target/mapit-spring.jar", "--wait")

                    }

                }

            }

        }

        stage('Promote to DEV') {

            steps {

                script {

                    openshift.withCluster() {

                        openshift.tag("mapit:latest", "mapit:dev")

                    }

                }

            }

        }

        stage('Create DEV') {

            when {

                expression {

                    openshift.withCluster() {

                        return !openshift.selector('dc', 'mapit-dev').exists()

                    }

                }

            }

            steps {

                script {

                    openshift.withCluster() {

                        openshift.newApp("mapit:latest", "--name=mapit-dev").narrow('svc').expose()

                    }

                }

            }

        }

        stage('Promote STAGE') {

            steps {

                script {

                    openshift.withCluster() {

                        openshift.tag("mapit:dev", "mapit:stage")

                    }

                }

            }

        }

        stage('Create STAGE') {

            when {

                expression {

                    openshift.withCluster() {

                        return !openshift.selector('dc', 'mapit-stage').exists()

                    }

                }

            }

            steps {

                script {

                    openshift.withCluster() {

                        openshift.newApp("mapit:stage", "--name=mapit-stage").narrow('svc').expose()

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