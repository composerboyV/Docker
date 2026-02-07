#!/bin/bash

# 데이터베이스 초기화
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

echo "Setting up permissions..."
chown -R mysql:mysql /var/lib/mysql
chmod -R 755 /var/lib/mysql

# 임시 init 파일 생성
INIT_FILE="/tmp/init.sql"
cat > "$INIT_FILE" << EOF
-- Root 비밀번호 설정
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';

-- WordPress 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;

-- WordPress 사용자 생성 및 권한 부여
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';

-- Docker 네트워크에서의 연결을 위한 추가 권한
CREATE USER IF NOT EXISTS '$DB_USER'@'%.inception' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%.inception';

-- 권한 적용
FLUSH PRIVILEGES;
EOF

# 임시 파일 권한 설정
chown mysql:mysql "$INIT_FILE"
chmod 644 "$INIT_FILE"

echo "Starting MariaDB with initialization script..."

# 초기화 완료 후 임시 파일 삭제를 위한 트랩 설정
trap 'rm -f "$INIT_FILE"' EXIT

# 포그라운드에서 MariaDB 실행
exec mysqld --user=mysql --init-file="$INIT_FILE"