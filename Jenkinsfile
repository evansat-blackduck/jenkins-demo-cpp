pipeline {
	
	agent any

	stages {
		stage("Init") {
		    steps {
		        script {
		            groovyScript = load "build.groovy"
		            os = groovyScript.findOS()
		            echo 'Building the application...'
		        }
		        // Ensure Python and pip are available
		        sh 'python3 --version || python --version'
		        sh 'pip3 --version || pip --version'
		
		        // Install Black Duck C/C++ scanner
		        sh 'pip install blackduck-c-cpp'
		    }
		}
		stage ('Clean') {
			steps {
				sh "git clean -fdx"
			}
		}

		stage('Build Server') {

			steps {
				sh "cd server && cmake . && make"
			}
		}

		stage('Build Client') {

			steps {
				sh "cd client && cmake . && make"
			}
		}
		
	}
}
