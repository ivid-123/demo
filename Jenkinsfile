
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

        APPLICATION_NAME = 'ng-tomcat-app'
        GIT_REPO = "https://github.com/ivid-123/demo.git"
        GIT_BRANCH = "master"
        STAGE_TAG = "promoteToQA"
        DEV_TAG = "1.0"
        DEV_PROJECT = "dev"
        STAGE_PROJECT = "stage"
        TEMPLATE_NAME = "ng-tomcat-app"
        ARTIFACT_FOLDER = "target"
        PORT = 80;
        MAIL_TO = 'ashish.mishra2@soprasteria.com,jenkinstestuser01@gmail.com'

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
        stage('Get Latest Code') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}" // declared in environment
            }
        }
        stage('cleanup') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            openshift.selector("all", [template : "${TEMPLATE_NAME}"]).delete()
                            if (openshift.selector("secrets", "${TEMPLATE_NAME}").exists()) {
                                openshift.selector("secrets", "${TEMPLATE_NAME}").delete()
                            }
                        }
                    }
                }
            }
        }
        stage('Install Packages') {
            steps {
                sh 'npm install'
                echo 'installing dependencies'
            }
        }
        stage('Validation'){
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
                            sh 'npm run test:phantom'
                        }
                    }
                }
            }
        }
        stage('Build App') {
            steps {
                script {
                    sh 'npm run build --prod'
                }
            }
        }
        stage('Store Artifact'){
            steps{
                script{
                    def safeBuildName = "${APPLICATION_NAME}_${BUILD_NUMBER}",
                        artifactFolder = "${ARTIFACT_FOLDER}",
                        fullFileName = "${safeBuildName}.tar.gz",
                        applicationZip = "${artifactFolder}/${fullFileName}"
                    applicationDir = ["src",
                        "dist",
                        "config",
                        "Dockerfile",
                    ].join(" ");
                    def needTargetPath = !fileExists("${artifactFolder}")
                    if (needTargetPath) {
                        sh "mkdir ${artifactFolder}"
                    }
                    sh "tar -czvf ${applicationZip} ${applicationDir}"
                    archiveArtifacts artifacts: "${applicationZip}", excludes: null, onlyIfSuccessful: true
                }
            }
        }

        stage('Create Image Builder') {
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject(DEV_PROJECT) {
                            echo 'selecting template'
                            return !openshift.selector("bc", "${TEMPLATE_NAME}").exists();
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(DEV_PROJECT) {
                            echo 'creating a new build configuration'
                            openshift.newBuild("--name=${TEMPLATE_NAME}", "--docker-image=docker.io/nginx:mainline-alpine", "--binary=true")
                            echo 'new build configuration created'
                        }

                    }
                }
            }
        }
        stage('Build Image') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(DEV_PROJECT) {
                            openshift.selector("bc", "${TEMPLATE_NAME}").startBuild("--from-archive=${ARTIFACT_FOLDER}/${APPLICATION_NAME}_${BUILD_NUMBER}.tar.gz", "--wait=true")
                        }
                    }
                }
            }
        }
        stage('Deploy to DEV') {
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject(DEV_PROJECT) {
                            return !openshift.selector('dc', "${TEMPLATE_NAME}").exists()
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(DEV_PROJECT) {
                            def app = openshift.newApp("${TEMPLATE_NAME}:latest")
                            app.narrow("svc").expose("--port=${PORT}");
                            def dc = openshift.selector("dc", "${TEMPLATE_NAME}")
                            while (dc.object().spec.replicas != dc.object().status.availableReplicas) {
                                // sleep 1
                            }
                        }
                    }
                }
            }
        }

        stage('Promote to STAGE?') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: "Promote to STAGE?", ok: "Promote"
                }
                script {
                    openshift.withCluster() {
                        openshift.tag("${DEV_PROJECT}/${TEMPLATE_NAME}:latest", "${STAGE_PROJECT}/${TEMPLATE_NAME}:${STAGE_TAG}")
                    }
                }
            }
        }

        stage('Rollout to STAGE') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(STAGE_PROJECT) {
                            if (openshift.selector('dc', '${TEMPLATE_NAME}').exists()) {
                                openshift.selector('dc', '${TEMPLATE_NAME}').delete()
                                openshift.selector('svc', '${TEMPLATE_NAME}').delete()
                                openshift.selector('route', '${TEMPLATE_NAME}').delete()
                            }
                            openshift.newApp("${TEMPLATE_NAME}:${STAGE_TAG}").narrow("svc").expose("--port=${PORT}")
                        }
                    }
                }
            }
        }
        stage('Scale in STAGE') {
            steps {
                script {
                    openshiftScale(namespace: "${STAGE_PROJECT}", deploymentConfig: "${TEMPLATE_NAME}", replicaCount: '2')
                }
            }
        }

    }
    post {
        // always {
        //     echo 'I will always say Hello again!'

        //     emailext body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
        //         recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']],
        //             subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}"

        // }
        // failure {
        //     mail to: "${MAIL_TO}", subject: 'The Pipeline failed:'
        // }
        // success {
        //     mail to: "${MAIL_TO}", subject: 'The Pipeline success:'
        // }
        success {
                        // cest = TimeZone.getTimeZone("CEST")
                        emailext body: '''${SCRIPT, template="email-html.template"}''',
                        //emailext body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
                        mimeType: 'text/html',
                        subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}",
                        to: "${MAIL_TO}",
                        replyTo: "${MAIL_TO}"
        }
        failure {

                        emailext body: '''${SCRIPT, template="email-html.template"}''',
                        mimeType: 'text/html',
                        subject: "[Jenkins] ${currentBuild.fullDisplayName}",
                        to: "${MAIL_TO}",
                        replyTo: "${MAIL_TO}",
                        recipientProviders: [[$class: 'CulpritsRecipientProvider']]
        }

    }

}