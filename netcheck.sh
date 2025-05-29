#!/bin/bash

echo "==== [네트워크 인터페이스 상태] ===="
ip addr show | grep -E '^[0-9]+|inet '

echo
echo "==== [기본 게이트웨이] ===="
ip route | grep default

echo
echo "==== [DNS 서버 확인] ===="
cat /etc/resolv.conf | grep nameserver

echo
echo "==== [인터넷 연결 확인(ping)] ===="
ping -c 2 8.8.8.8
ping -c 2 archive.ubuntu.com

echo
echo "==== [패키지 저장소 접속 테스트(curl)] ===="
curl -I http://archive.ubuntu.com/ubuntu/
curl -I http://security.ubuntu.com/ubuntu/

echo
echo "==== [80/443 포트 접근 테스트(nc)] ===="
nc -zv archive.ubuntu.com 80
nc -zv archive.ubuntu.com 443

echo
echo "==== [docker0 네트워크 상태] ===="
ip addr show docker0 2>/dev/null || echo "docker0 인터페이스 없음"

echo
echo "==== [Docker 데몬 상태] ===="
systemctl status docker | grep -E 'Active|Loaded'

echo
echo "==== [도커 컨테이너 실행 중 목록] ===="
docker ps

echo
echo "==== [네트워크 경로 traceroute (선택)] ===="
traceroute archive.ubuntu.com || echo "traceroute 미설치"

