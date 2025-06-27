pipeline {
    agent any

    environment {
        BLACKDUCK_API_TOKEN = credentials('BLACKDUCK_API_TOKEN')
        CC = 'gcc'
        CXX = 'g++'
    }

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

        stage('Clean') {
            steps {
                sh '''
                    git clean -fdx
                    rm -rf ~/.blackduck/blackduck-c-cpp/output/*
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

                    echo "#!/bin/bash" > build_all.sh
                    echo "cd server && cmake . && make VERBOSE=1" >> build_all.sh
                    echo "cd ../client && cmake . && make VERBOSE=1" >> build_all.sh
                    chmod +x build_all.sh

                    echo "Listing workspace after Init:"
                    find . -name "activate_venv.sh"
                '''
            }
        }

        stage('Build (for verification)') {
            steps {
                sh './build_all.sh'
            }
        }

        stage('Black Duck Scan') {
            steps {
                sh '''
                    echo "Sourcing virtual environment..."
                    if [ ! -f "$WORKSPACE/activate_venv.sh" ]; then
                        echo "ERROR: activate_venv.sh not found!"
                        exit 1
                    fi
                    . "$WORKSPACE/activate_venv.sh"

                    echo "Scanning server..."
                    cd server
                    blackduck-c-cpp \
                        --bd_url https://evansat-bd.illcommotion.com \
                        --api_token $BLACKDUCK_API_TOKEN \
                        --project_name jenkins-demo-cpp \
                        --project_version 1.0.0 \
                        --additional_sig_scan_args="--snippet-matching" \
                        --skip_build false \
                        --skip_transitives false \
                        --build_cmd 'rm -rf build && cmake . && make VERBOSE=1' \
                        --build_dir "$WORKSPACE/server" \
                        --verbose true \
                        --debug true
                    cd ..

                    echo "Scanning client..."
                    cd client
                    blackduck-c-cpp \
                        --bd_url https://evansat-bd.illcommotion.com \
                        --api_token $BLACKDUCK_API_TOKEN \
                        --project_name jenkins-demo-cpp \
                        --project_version 1.0.0 \
                        --additional_sig_scan_args="--snippet-matching" \
                        --skip_build false \
                        --skip_transitives false \
                        --build_cmd 'rm -rf build && cmake . && make VERBOSE=1' \
                        --build_dir "$WORKSPACE/client" \
                        --verbose true \
                        --debug true
                    cd ..
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed. Cleaning up...'
        }
        failure {
            echo 'Pipeline failed. Please check logs for details.'
        }
    }
}
