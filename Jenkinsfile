pipeline {
	
	agent any

	stages {
		stage("Init") {
		    steps {
		        // Check Python and pip availability
		        sh 'python3 --version || python --version'
		        sh 'pip3 --version || pip --version'
		
		        // Install Black Duck C/C++ scanner
		        sh 'pip3 install blackduck-c-cpp'
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
