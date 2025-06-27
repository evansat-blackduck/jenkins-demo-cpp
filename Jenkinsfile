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
		stage('Black Duck Scan') {
		    steps {
		        sh '''
		            blackduck-c-cpp scan \
				  --bd_url https://your.blackduck.server \
				  --api_token $BLACKDUCK_API_TOKEN \
				  --project_name jenkins-demo-cpp \
				  --project_version 1.0.0 \
				  --path ./server \
				  --build_cmd "make" \
				  --build_dir ./

		        '''
		    }
		}
	}
}
