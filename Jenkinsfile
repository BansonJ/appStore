pipeline {
    agent any

    environment {
        // Docker Hub 서버 주소 (로그인 시 사용)
        DOCKER_SERVER = 'docker.io'
        
        // 이미지 저장소 경로 (사용자명/레포지토리명)
        DOCKER_REGISTRY = 'bansonj/project1' // <-- 이미지 경로 (로그인 후 푸시 대상)
        
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        
        // FULL_IMAGE_NAME을 'bansonj/project1:3' 형태로 올바르게 정의
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY}:${IMAGE_TAG}" 
        
        DOCKER_CREDENTIAL_ID = 'docker_key'
    }

    stages {
        // ... (Checkout Source Code 단계는 동일)

        stage('Build Docker Image') {
            steps {
                script {
                    // echo 명령어에서 사용되지 않는 DOCKER_REPOSITORY 대신 DOCKER_REGISTRY 사용
                    echo "Building Docker image: ${DOCKER_REGISTRY}:${IMAGE_TAG}" 
                    
                    // 1. 이미지 빌드 (로컬 태그는 간단하게 지정)
                    sh "docker build -t ${DOCKER_REGISTRY}:${IMAGE_TAG} ." // <-- 여기서 DOCKER_REGISTRY 사용
                    
                    // 2. 이전에 이미 FULL_IMAGE_NAME으로 태그를 지정했으므로, 이 줄은 불필요하거나, 
                    // 로컬 태그를 단순하게 지정했다면 FULL_IMAGE_NAME으로 태그를 지정해야 합니다.
                    // 위에서 DOCKER_REGISTRY로 빌드했으므로, 이 줄은 주석 처리합니다.
                    // sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}"
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIAL_ID}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    
                    // 로그인 서버 주소를 'docker.io'로 수정 (DOCKER_SERVER 사용)
                    sh "echo \$DOCKER_PASSWORD | docker login ${DOCKER_SERVER} --username \$DOCKER_USERNAME --password-stdin"
                    
                    echo "Pushing Docker image: ${FULL_IMAGE_NAME}"
                    sh "docker push ${FULL_IMAGE_NAME}"
                    
                    // (선택) latest 태그 푸시
                    sh "docker tag ${FULL_IMAGE_NAME} ${DOCKER_REGISTRY}:latest"
                    sh "docker push ${DOCKER_REGISTRY}:latest"
                }
            }
        }

        stage('Cleanup') {
             steps {
                 // DOCKER_REGISTRY와 FULL_IMAGE_NAME만 사용하도록 수정
                 sh "docker rmi -f ${FULL_IMAGE_NAME}"
                 sh "docker rmi -f ${DOCKER_REGISTRY}:latest"
             }
        }
    }
}
