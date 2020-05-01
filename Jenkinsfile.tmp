pipeline {

    agent {

        label 'nodejs'

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
        PORT = 8081;

    }

    stages {

        stage('Build App') {

            steps {

                sh "npm install"

            }

        }

        stage('Create Image Builder') {

            when {

                expression {

                    openshift.withCluster() {

                        return !openshift.selector("bc", "ng-tomcat-app").exists();

                    }

                }

            }

            steps {

                script {

                    openshift.withCluster() {

                        openshift.newBuild("--name=ng-tomcat-app", "--image-stream=redhat-openjdk18-openshift:1.1", "--binary")

                    }

                }

            }

        }

        stage('Build Image') {

            steps {

                script {

                    openshift.withCluster() {

                        openshift.selector("bc", "ng-tomcat-app").startBuild("--from-file=target/ng-tomcat-app-spring.jar", "--wait")

                    }

                }

            }

        }

        stage('Promote to DEV') {

            steps {

                script {

                    openshift.withCluster() {

                        openshift.tag("ng-tomcat-app:latest", "ng-tomcat-app:dev")

                    }

                }

            }

        }

        stage('Create DEV') {

            when {

                expression {

                    openshift.withCluster() {

                        return !openshift.selector('dc', 'ng-tomcat-app-dev').exists()

                    }

                }

            }

            steps {

                script {

                    openshift.withCluster() {

                        openshift.newApp("ng-tomcat-app:latest", "--name=ng-tomcat-app-dev").narrow('svc').expose()

                    }

                }

            }

        }

        stage('Promote STAGE') {

            steps {

                script {

                    openshift.withCluster() {

                        openshift.tag("ng-tomcat-app:dev", "ng-tomcat-app:stage")

                    }

                }

            }

        }

        stage('Create STAGE') {

            when {

                expression {

                    openshift.withCluster() {

                        return !openshift.selector('dc', 'ng-tomcat-app-stage').exists()

                    }

                }

            }

            steps {

                script {

                    openshift.withCluster() {

                        openshift.newApp("ng-tomcat-app:stage", "--name=ng-tomcat-app-stage").narrow('svc').expose()

                    }

                }

            }

        }

    }

}