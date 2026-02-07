#!/bin/bash

echo "Waiting for MariaDB to be ready..."
sleep 10

# CLI에서 사용할 HTTP_HOST 환경변수 설정
export HTTP_HOST="junkwak.42.fr"

# WordPress 설치 및 설정
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root
    
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST:3306" \
        --dbcharset="utf8" \
        --extra-php \
        --allow-root \
        --skip-check << 'EOF'
define('WP_ALLOW_REPAIR', true);
define('WP_DEBUG', true);

// 댓글 관리자 승인 없이 게시
define('WP_COMMENT_MODERATION', 0);

// SSL/HTTPS 설정
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

// HTTPS URL 강제 설정
define('WP_HOME','https://' . $_SERVER['HTTP_HOST']);
define('WP_SITEURL','https://' . $_SERVER['HTTP_HOST']);

// 관리자 페이지 SSL 강제
define('FORCE_SSL_ADMIN', true);

// 쿠키 보안 설정
ini_set('session.cookie_secure', 1);
ini_set('session.cookie_httponly', 1);

// CLI에서 HTTP_HOST 설정
if (!isset($_SERVER['HTTP_HOST'])) {
    $_SERVER['HTTP_HOST'] = 'junkwak.42.fr';
}
EOF

    echo "Generating security keys..."
    wp config shuffle-salts --allow-root
    
    echo "Installing WordPress..."
    wp core install \
        --url="https://junkwak.42.fr" \
        --title="My WordPress Site" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    # 추가 사용자가 환경변수로 정의되어 있다면 생성
    # 현재 .env에는 WP_USER 관련 변수가 없으므로 이 부분은 실행되지 않음
    if [ ! -z "$WP_USER" ] && [ ! -z "$WP_USER_PASSWORD" ] && [ ! -z "$WP_USER_EMAIL" ]; then
        echo "Creating regular user..."
        wp user create "$WP_USER" "$WP_USER_EMAIL" \
            --user_pass="$WP_USER_PASSWORD" \
            --role=author \
            --allow-root
    else
        echo "No additional user configured. Only admin user created."
    fi
    
    echo "WordPress installation completed!"
else
    echo "WordPress is already installed."
fi

# 파일 권한 설정
echo "Setting up file permissions..."
chown -R www-data:www-data /var/www/html/
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM..."
exec php-fpm8.2 --nodaemonize