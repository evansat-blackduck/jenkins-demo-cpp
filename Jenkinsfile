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

        stage('Black Duck C++ Scan') {
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
                        --project_version 2.0.0 \
                        --additional_sig_scan_args="--snippet-matching" \
                        --skip_build false \
                        --skip_transitives false \
                        --build_cmd 'cmake . && make clean && make VERBOSE=1' \
                        --build_dir . \
                        --verbose true \
                        --debug true
                    cd ..

                    echo "Scanning client..."
                    cd client
                    blackduck-c-cpp \
                        --bd_url https://evansat-bd.illcommotion.com \
                        --api_token $BLACKDUCK_API_TOKEN \
                        --project_name jenkins-demo-cpp \
                        --project_version 2.0.0 \
                        --additional_sig_scan_args="--snippet-matching" \
                        --skip_build false \
                        --skip_transitives false \
                        --build_cmd 'cmake . && make clean && make VERBOSE=1' \
                        --build_dir . \
                        --verbose true \
                        --debug true
                    cd ..
                '''
            }
        }

        stage('Black Duck Detect Policy Violation Scan') {
            steps {
                sh '''
                    echo "Downloading Black Duck Detect script..."
                    curl -s -L -o detect10.sh https://detect.blackduck.com/detect10.sh
                    chmod +x detect10.sh

                    echo "Running Black Duck Detect..."
                    bash detect10.sh \
                        --blackduck.url=https://evansat-bd.illcommotion.com \
                        --blackduck.api.token=$BLACKDUCK_API_TOKEN \
                        --detect.project.name=jenkins-demo-cpp \
                        --detect.project.version.name=2.0.0 \
                        --detect.source.path=. \
                        --detect.tools.excluded=DETECTOR,SIGNATURE_SCAN,IMPACT_ANALYSIS,DOCKER,BAZEL,IAC_SCAN,CONTAINER_SCAN,THREAT_INTEL,COMPONENT_LOCATION_ANALYSIS \
                        // --detect.policy.check.fail.on.severities=BLOCKER,CRITICAL \
                        --detect.wait.for.results=true \
                        --detect.verbose=true
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
