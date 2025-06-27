pipeline {
	
	agent any

	stages {
		stage('Inspect Workspace') {
	            steps {
	                sh '''
	                    echo "WORKSPACE: $WORKSPACE"
	                    echo "Listing contents of workspace:"
	                    ls -la "$WORKSPACE"
	                '''
	            }
	        }
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
				  --bd_url https://evansat-bd.illcommotion.com \
				  --api_token $BLACKDUCK_API_TOKEN \
				  --project_name jenkins-demo-cpp \
				  --project_version 1.0.0 \
      				  --additional_sig_scan_args: '--snippet-matching' \
      				  --skip_build false \
	    			  --skip_transitives false \
				  --build_cmd "make" \
				  --build_dir "$WORKSPACE" \
      				  --verbose true

		        '''
		    }
		}
	}
}
