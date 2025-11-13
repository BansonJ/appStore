pipeline {
    agent any // 빌드를 실행할 에이전트 (Jenkins 서버 자체 또는 노드)

    // 파이프라인에서 사용할 환경 변수 정의
    environment {
        // 도커 레지스트리 주소와 이미지 이름 설정
		DOCKER_SERVER = 'docker.io'
        DOCKER_REGISTRY = 'bansonj/project1' // 예: 'docker.io/myuser' 또는 'harbor.mycompany.com'
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
                    echo "Building Docker image: ${DOCKER_REPOSITORY}:${IMAGE_TAG}"
                    // 1. 이미지 빌드 (로컬 태그 사용)
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ." 
                    // 2. 푸시할 레지스트리 경로로 태그 지정
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}" 
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIAL_ID}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    
                    // 로그인 서버 주소를 'docker.io'로 수정
                    sh "echo \$DOCKER_PASSWORD | docker login ${DOCKER_SERVER} --username \$DOCKER_USERNAME --password-stdin"
                    
                    echo "Pushing Docker image: ${FULL_IMAGE_NAME}"
                    // 이미지 푸시 (FULL_IMAGE_NAME은 'bansonj/project1:3' 형태)
                    sh "docker push ${FULL_IMAGE_NAME}"
                    
                    // (선택) latest 태그 푸시
                    sh "docker tag ${FULL_IMAGE_NAME} ${DOCKER_REPOSITORY}:latest"
                    sh "docker push ${DOCKER_REPOSITORY}:latest"
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
