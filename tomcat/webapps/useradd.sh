#!/bin/bash

# DB 접속 정보
DB_USER="test"
DB_PASS="test"
DB_NAME="my_database"

# 사용자 삽입
for i in $(seq -w 1 5); do
  username="user$i"
  email="user$i@example.com"
  password="pass$i"

  # Python으로 PBKDF2 해시 생성
  final=$(python3 -c "
import hashlib, base64, os
password = b'$password'
salt = os.urandom(16)
dk = hashlib.pbkdf2_hmac('sha256', password, salt, 10000, dklen=32)
print(base64.b64encode(salt).decode() + ':' + base64.b64encode(dk).decode())
")

  # MySQL에 삽입
  mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e \
    "INSERT INTO users (username, email, password) VALUES ('$username', '$email', '$final');"
done

echo "[  OK  ] 사용자 user01 ~ user05 (PBKDF2 해시) 삽입 완료"
