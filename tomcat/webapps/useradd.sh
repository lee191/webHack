#!/bin/bash

# DB 접속 정보
DB_USER="test"
DB_PASS="test"
DB_NAME="my_database"

# 사용자 반복 삽입 (비밀번호는 MD5 해시 사용)
for i in $(seq -w 1 5); do
  username="user$i"
  email="user$i@example.com"
  password="pass$i"

  # INSERT SQL 실행 (패스워드를 MD5로 암호화)
  mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e \
    "INSERT INTO users (username, email, password) VALUES ('$username', '$email', MD5('$password'));"
done

echo "[  OK  ]사용자 user01 ~ user05 (MD5 암호화) 삽입 완료"
