# 1. 베이스 이미지 설정 (Node.js의 공식 경량 이미지)
FROM node:18-alpine

# 2. 작업 디렉토리 설정
WORKDIR /usr/src/app

# 3. 애플리케이션 의존성 설치
# package.json과 package-lock.json 파일만 복사하여 캐시 활용도를 높임
COPY package*.json ./
RUN npm install --only=production

# 4. 소스 코드 복사
# 나머지 모든 소스 코드를 작업 디렉토리로 복사
COPY . .

# 5. 컨테이너가 리스닝할 포트 노출 (선택 사항이지만 권장)
EXPOSE 8080

# 6. 컨테이너 시작 시 실행할 명령
CMD [ "npm", "start" ]
