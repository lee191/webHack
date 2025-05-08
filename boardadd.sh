#!/bin/bash

# DB 접속 정보
DB_HOST="localhost"
DB_USER="test"
DB_PASS="test"
DB_NAME="my_database"

# 반복하여 게시글 10개 추가
for i in {1..10}; do
  TITLE="테스트 제목 $i"
  CONTENT="이것은 자동으로 생성된 테스트 내용입니다. 번호: $i"
  USERNAME="admin"
  FILENAME="file$i.txt"
  CREATED_AT=$(date "+%Y-%m-%d %H:%M:%S")

  # INSERT 실행
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
INSERT INTO posts (username, title, content, filename, created_at)
VALUES ('$USERNAME', '$TITLE', '$CONTENT', '$FILENAME', '$CREATED_AT');
EOF

  echo "[$i] 게시글 추가 완료"
done