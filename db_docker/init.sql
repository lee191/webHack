-- 사용자 생성 및 권한 부여
CREATE USER 'test'@'%' IDENTIFIED BY 'test';
GRANT ALL PRIVILEGES ON my_database.* TO 'test'@'%';
FLUSH PRIVILEGES;

-- 데이터베이스 생성 및 선택
CREATE DATABASE IF NOT EXISTS my_database CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE my_database;

-- 테이블 생성
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(128) NOT NULL
);

CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    filename VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 인코딩 보장 (추가적 보정)
ALTER DATABASE my_database CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE posts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
