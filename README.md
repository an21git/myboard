# 簡易掲示板
CODEBASE受講生向けの簡易掲示板サンプル
 
## データベース構築
動作の確認をしたい方は、以下のSQL文を実行して下さい。
```
CREATE DATABASE myboard;
```
```
CREATE TABLE users(
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  email VARCHAR(50) NOT NULL,
  password VARCHAR(20) NOT NULL,
  introduce VARCHAR(20)
  birthday DATE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
```
```
CREATE TABLE posts(
  id SERIAL NOT NULL PRIMARY KEY,
  title VARCHAR(20) NOT NULL,
  content VARCHAR(255) NOT NULL,
  image VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
```
```
CREATE TABLE follower(
  id SERIAL NOT NULL PRIMARY KEY,
  following INTEGER NOT NULL,
  followed INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
```