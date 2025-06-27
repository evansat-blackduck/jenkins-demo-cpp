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
                sh '''
                    python3.8 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install Cython==0.29.36
                    pip install numpy==1.24.4
                    pip install blackduck-c-cpp
                    echo ". $(pwd)/venv/bin/activate" > activate_venv.sh
                    chmod +x activate_venv.sh
                    ls -l activate_venv.sh
                '''
            }
        }
        stage('Clean') {
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
                    echo "Sourcing virtual environment..."
                    if [ ! -f activate_venv.sh ]; then
                        echo "ERROR: activate_venv.sh not found!"
                        exit 1
                    fi
                    cat activate_venv.sh
                    . activate_venv.sh
                    blackduck-c-cpp \
                        --bd_url https://evansat-bd.illcommotion.com \
                        --api_token $BLACKDUCK_API_TOKEN \
                        --project_name jenkins-demo-cpp \
                        --project_version 1.0.0 \
                        --additional_sig_scan_args '--snippet-matching' \
                        --skip_build false \
                        --skip_transitives false \
                        --build_cmd 'make' \
                        --build_dir "$WORKSPACE" \
                        --verbose true
                '''
            }
        }
    }
}
