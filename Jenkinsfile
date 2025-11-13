pipeline {
    agent any // 빌드를 실행할 에이전트 (Jenkins 서버 자체 또는 노드)

    // 파이프라인에서 사용할 환경 변수 정의
    environment {
        // 도커 레지스트리 주소와 이미지 이름 설정
        DOCKER_REGISTRY = 'hub.docker.com/repositories/bansonj' // 예: 'docker.io/myuser' 또는 'harbor.mycompany.com'
        IMAGE_NAME = "project1"
        IMAGE_TAG = "${env.BUILD_NUMBER}" // Jenkins 빌드 번호를 태그로 사용
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKER_CREDENTIAL_ID = 'docker_key' // 1.3에서 등록한 Credentials ID
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                // GitHub 웹훅에 의해 트리거된 커밋 소스 코드를 가져옴
                git branch: 'main', url: 'https://github.com/BansonJ/appStore.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Dockerfile을 사용하여 이미지 빌드
                    echo "Building Docker image: ${FULL_IMAGE_NAME}"
                    // 빌드 후 바로 태그를 지정하여 다음 단계에서 사용
                    sh "docker build -t ${FULL_IMAGE_NAME} ." 
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                // Jenkins에 등록된 인증 정보를 사용하여 로그인 후 Push
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIAL_ID}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login ${DOCKER_REGISTRY} --username \$DOCKER_USERNAME --password-stdin"
                    
                    echo "Pushing Docker image: ${FULL_IMAGE_NAME}"
                    // Docker 레지스트리로 이미지 푸시
                    sh "docker push ${FULL_IMAGE_NAME}"
                }
            }
        }

        stage('Cleanup') {
            steps {
                // 로컬에서 사용한 이미지 삭제 (선택 사항)
                sh "docker rmi -f ${FULL_IMAGE_NAME}"
                sh "docker rmi -f ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
            }
        }
    }
}
