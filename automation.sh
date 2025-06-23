#!/bin/bash

exec >> /media/chan/LCW/automation.log 2>&1

##### Automation 시스템 자동화 #####

AUTOMATION_PATH="/media/chan/LCW/Justick_system"
cd "$AUTOMATION_PATH" || exit 1

git fetch origin

AUTOMATION_CHANGED=false
if [[ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]]; then
    AUTOMATION_CHANGED=true
    echo "[AUTOMATION] 변경사항 발견! pull 실행"
    git pull origin main || { echo "[AUTOMATION] git pull 실패!"; exit 1; }
else
    echo "[AUTOMATION] 변경사항 없음"
fi

##### Justick_front 자동화 #####

FRONT_PATH="/media/chan/LCW/Justick_front"
cd "$FRONT_PATH" || exit 1

git fetch origin

FRONT_CHANGED=false
if [[ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]]; then
    FRONT_CHANGED=true
    echo "[FRONT] 변경사항 발견! pull 후 build 시작"
    git pull origin main || { echo "[FRONT] git pull 실패!"; exit 1; }

    echo "[FRONT] npm install"
    npm install || { echo "[FRONT] npm install 실패!"; exit 1; }

    echo "[FRONT] npm run build"
    npm run build || { echo "[FRONT] 빌드 실패!"; exit 1; }

    echo "[FRONT] nginx reload"
    sudo systemctl reload nginx && echo "[FRONT] nginx complete" || echo "[FRONT] nginx reload 실패!"
else
    echo "[FRONT] 변경사항 없음"
fi

##### Justick_back 자동화 #####

SPRING_PATH="/media/chan/LCW/Justick_back"
cd "$SPRING_PATH" || exit 1

git fetch origin

SPRING_CHANGED=false
if [[ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]]; then
    SPRING_CHANGED=true
    echo "[SPRING] 변경사항 발견! pull 후 build 시작"
    git pull origin main || { echo "[SPRING] git pull 실패!"; exit 1; }

    # gradlew 실행권한 보장
    chmod +x ./Justick/gradlew

    echo "[SPRING] gradlew clean build -x test"
    (cd Justick && JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64 ./gradlew clean build -x test) || { echo "[SPRING] 빌드 실패!"; exit 1; }

    # 빌드된 jar 복사
    JAR_SRC="$SPRING_PATH/Justick/build/libs/Justick-0.0.2.jar"
    JAR_DST="/media/chan/LCW/Justick_server/Justick-0.0.2.jar"

    if [ -f "$JAR_SRC" ]; then
        cp "$JAR_SRC" "$JAR_DST" && echo "[SPRING] jar 복사 완료: $JAR_DST"
    else
        echo "[SPRING] 빌드 후 jar 파일이 존재하지 않습니다!"
        exit 1
    fi

    # 도커 재시작
    echo "[SPRING] Docker compose 재시작"
    cd /media/chan/LCW/Justick_server
    sudo docker compose down
    sudo docker compose build --no-cache
    sudo docker compose up -d && echo "[SPRING] Docker compose up 완료"
else
    echo "[SPRING] 변경사항 없음"
fi

if [ "$AUTOMATION_CHANGED" = false ] && [ "$FRONT_CHANGED" = false ] && [ "$SPRING_CHANGED" = false ]; then
    echo "전체적으로 변경사항 없음. 아무 작업도 안 함."
fi

