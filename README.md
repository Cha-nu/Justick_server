# Justick_server

서버 컴퓨터의 설정파일입니다.  
적절한 파일 배치가 필요합니다.  

## NGINX
nginx를 설치합니다.  
sudo apt update  
sudo apt install nginx  
  
명령어로 nginx 파일을 적절한 곳에 배치시킵니다.
sudo mv my_proxy /etc/nginx/sites-available/my_proxy  

(optional) nginx 파일을 서버에 맞게 수정합니다.
vi /etc/nginx/sites-available/my_proxy  
  
파일을 적용시킵니다.  
sudo ln -s /etc/nginx/sites-available/my_proxy /etc/nginx/sites-enabled/  
sudo nginx -t  
sudo systemctl reload nginx  

## Service, Timer
system-wide 서비스 파일 이동시킵니다.
sudo mv automation.{service,timer} /etc/systemd/system/  
  
user-level 서비스 파일을 이동시킵니다.
mv justick.{service,timer} ~/.config/systemd/user/  

service 파일을 수정합니다. 
sudo vi automation /etc/systemd/system/automation.service #automation.sh 경로를 설정합니다.  
vi ~/.config/systemd/user/ justick.service # justick_system의 main.py 경로를 설정합니다.

justick_system 파일이 설치되어 있어야합니다.  
https://github.com/Cha-nu/Justick_system
  
시스템 단위 서비스/타이머 재로드 (수정한 후 필수)  
sudo systemctl daemon-reload  
systemctl --user daemon-reload  
  
타이머 등록 (부팅 시 자동 시작)  
sudo systemctl enable automation.timer  
systemctl --user enable justick.timer  

타이머 시작  
sudo systemctl start automation.timer  
systemctl --user start justick.timer  

## automation.sh  
root 권한으로 git config가 설정되어 있어야합니다.


완료되면 오전 8시에 크롤러가 작동되는 것을 확인할 수 있습니다.  
![image](https://github.com/user-attachments/assets/3ff22f47-4d09-4c10-bc9e-7e7b394a975d)

## docker 실행
sudo docker compose build --no-cache # docker를 빌드합니다.
sudo docker compose up -d # docker를 실행합니다.
