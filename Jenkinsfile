pipeline {
    agent {
        node {
			    label 'nodejs'
		    }
    }
    environment {
        CI = 'true'
    }
    stages {
	      stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
		    stage('Quality Analysis') {
            steps {
                sh './jenkins/scripts/quality/lint.sh'
            }
			      steps {
                sh './jenkins/scripts/quality/sonar.sh'
            }
        }
		    stage('Unit Test') {
			      when {
                branch 'development' 
            }
            steps {
                sh './jenkins/scripts/test.sh'
            }
        }
		
        stage('Build') {
			      steps {
                sh './jenkins/scripts/build.sh'
				        echo : 'a versioned package for your the artifacts repository'
            }
        }
		    stage('package') {
            steps {
                echo : 'apply configuration of specific enviorment and does versioning of build images then made it available for the artifacts repository'
            }
        }
        stage('Deploy on Dev') {
            when {
                branch 'development' 
            }
            steps {
                sh './jenkins/scripts/deliver-for-development.sh'
               // input message: 'Finished using the web site? (Click "Proceed" to continue)'
                //sh './jenkins/scripts/kill.sh'
            }
        }
		    stage('Deploy on Stage') {
            when {
                branch 'stage'  
            }
            steps {
                sh './jenkins/scripts/deploy-for-production.sh'
                input message: 'Finished using the web site? (Click "Proceed" to continue)'
                sh './jenkins/scripts/kill.sh'
            }
        }
        stage('Deploy for production') {
            when {
                branch 'production'  
            }
            steps {
                sh './jenkins/scripts/deploy-for-production.sh'
                input message: 'Finished using the web site? (Click "Proceed" to continue)'
                sh './jenkins/scripts/kill.sh'
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
		    stage('tag') {
		        steps {
			        script {
				        echo 'create tags on stage build images'
		        	}
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