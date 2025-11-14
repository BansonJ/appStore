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
        
        GITOPS_REPO_URL = 'https://github.com/BansonJ/gitOps.git' // <-- GitOps 레포지토리 URL로 변경하세요
        GITOPS_BRANCH = 'main' // <-- GitOps 레포지토리의 브랜치로 변경하세요
        GITOPS_CREDENTIAL_ID = 'github_key' // <-- GitOps 레포지토리에 푸시할 권한이 있는 Jenkins Credential ID로 변경하세요 (일반적으로 SSH Key 또는 Username/Password)
        GITOPS_FILE_PATH = 'app-deployment.yaml' // <-- 태그를 변경할 파일 경로로 변경하세요 (예시)
        GITOPS_WORKSPACE = 'gitops-work'
    }

    stages {
    
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
        
        stage('Update GitHub Tag (Manual)') {
            steps {
                // withCredentials 블록을 dir 안에 배치하여, 이 안에서 Git 인증 정보를 사용합니다.
                withCredentials([usernamePassword(credentialsId: "${GITOPS_CREDENTIAL_ID}", 
                                                   passwordVariable: 'GITOPS_TOKEN', 
                                                   usernameVariable: 'GITOPS_USERNAME')]) {
                    dir("${GITOPS_WORKSPACE}") {
                        
                        // 1. (생략) GitHub 레포지토리 체크아웃은 이미 성공했습니다.
                        // (checkout 스텝은 withCredentials 바깥에 있어도 무방하지만, 이 경우 URL이 HTTPS여야 합니다.)
                        // 현재 GITOPS_REPO_URL이 HTTPS라고 가정하고 진행합니다.
                        // GITOPS_REPO_URL = 'https://github.com/BansonJ/gitOps.git' 여야 합니다.
                        
                        // 2. 브랜치 전환 및 작업
                        sh 'git checkout -b main' 
                        
                        // 3. yq를 사용하여 YAML 파일 내 이미지 필드 업데이트
                        sh "yq e '.spec.template.spec.containers[0].image = \"${FULL_IMAGE_NAME}\"' -i ${GITOPS_FILE_PATH}" 
                        
                        // 4. 변경 사항 커밋
                        sh 'git config user.email "wjdtmdgus0313@gmail.com"'
                        sh 'git config user.name "Banson"'
                        sh "git add ${GITOPS_FILE_PATH}"
                        sh 'git diff-index --quiet HEAD || git commit -m "CI: Update image tag to ${IMAGE_TAG}"'

                        // ⭐⭐⭐ 5. GIT_ASKPASS를 사용하여 푸시 (핵심 수정 사항) ⭐⭐⭐
                        // Jenkins Credentials Binding Plugin이 제공하는 방식으로 인증을 처리합니다.
                        sh """
                        # GIT_ASKPASS를 사용하여 자격 증명(사용자명/토큰)을 자동으로 제공합니다.
                        GIT_ASKPASS="/usr/bin/echo" git push https://${GITOPS_USERNAME}:${GITOPS_TOKEN}@github.com/BansonJ/gitOps.git main
                        """
                        
                        echo "Changes pushed to GitHub. ArgoCD will now sync."
                    }
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
