
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
        DEV_PROJECT = "dev"
        STAGE_PROJECT = "stage"
        TEMPLATE_NAME = "ng-tomcat-app"
        ARTIFACT_FOLDER = "target"
        PORT = 8081;

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

        stage('Store Artifact'){
            steps{
                script{
                    def safeBuildName = "${APPLICATION_NAME}_${BUILD_NUMBER}",
                        artifactFolder = "${ARTIFACT_FOLDER}",
                        fullFileName = "${safeBuildName}.tar.gz",
                        applicationZip = "${artifactFolder}/${fullFileName}"
                    applicationDir = ["src",
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
                            return !openshift.selector("bc", "${TEMPLATE_NAME}").exists();
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(DEV_PROJECT) {
                            openshift.newBuild("--name=${TEMPLATE_NAME}", "--docker-image=docker.io/vipyangyang/jenkins-agent-nodejs-10:v3.11", "--binary=true")
                        }
                    }
                }
            }
        }

        stage('Build Image') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(env.DEV_PROJECT) {
                            openshift.selector("bc", "$TEMPLATE_NAME").startBuild("--from-archive=${ARTIFACT_FOLDER}/${APPLICATION_NAME}_${BUILD_NUMBER}.tar.gz", "--wait=true")
                        }
                    }
                }
            }
        }

        stage('Deploy to DEV') {
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject(env.DEV_PROJECT) {
                            return !openshift.selector('dc', "${TEMPLATE_NAME}").exists()
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(env.DEV_PROJECT) {
                            def app = openshift.newApp("${TEMPLATE_NAME}:latest")
                            app.narrow("svc").expose("--port=${PORT}");
                            def dc = openshift.selector("dc", "${TEMPLATE_NAME}")
                            while (dc.object().spec.replicas != dc.object().status.availableReplicas) {
                                sleep 10
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
                    openshiftScale(namespace: "${STAGE_PROJECT}", deploymentConfig: "${TEMPLATE_NAME}", replicaCount: '3')
                }
            }
        }

    }

}