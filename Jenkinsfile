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
		        sh 'python3.8 --version || python --version'
		        sh 'pip3 --version || pip --version'
			sh 'python3.8 -m venv venv'
        		sh 'bash -c "source venv/bin/activate && pip install blackduck-c-cpp"'
        		sh 'echo "source $WORKSPACE/venv/bin/activate" > activate_venv.sh'

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
			    bash -c "source activate_venv.sh && blackduck-c-cpp \
			              --bd_url https://evansat-bd.illcommotion.com \
			              --api_token $BLACKDUCK_API_TOKEN \
			              --project_name jenkins-demo-cpp \
			              --project_version 1.0.0 \
			              --additional_sig_scan_args '--snippet-matching' \
			              --skip_build false \
			              --skip_transitives false \
			              --build_cmd 'make' \
			              --build_dir '$WORKSPACE' \
			              --verbose true"
			        '''
			    }
		}
	}
}
