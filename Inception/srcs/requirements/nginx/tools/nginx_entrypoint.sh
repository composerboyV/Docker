#!/bin/bash

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/junkwak.42.fr.key \
    -out /etc/ssl/certs/junkwak.42.fr.crt \
    -subj "/C=KR/ST=Gyeongsangbuk-do/L=Gyeongsan/O=42Gyeongsan/OU=Cadet/CN=junkwak.42.fr"

chmod 600 /etc/ssl/private/junkwak.42.fr.key
chmod 644 /etc/ssl/certs/junkwak.42.fr.crt

# nginx.conf 생성
# /etc/nginx/nginx.conf /etc/nginx/fastcgi.conf 참고
cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
}

http {
    # 기본 설정
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;
    server_tokens off;

    # 로깅
    access_log /var/log/nginx/access.log;
    
    server {
        listen 443 ssl;
        listen [::]:443 ssl;

        server_name junkwak.42.fr;
        root /var/www/html;
        index index.php index.html index.htm;

        # SSL 설정
        ssl_certificate /etc/ssl/certs/junkwak.42.fr.crt;
        ssl_certificate_key /etc/ssl/private/junkwak.42.fr.key;
        ssl_protocols TLSv1.2 TLSv1.3;


        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            if (!-f $document_root$fastcgi_script_name)
            { 
                return 404;
            }
            try_files $uri =404;
            include fastcgi_params;
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }

        # 정적 파일 캐싱
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# nginx 포그라운드 실행
exec nginx -g "daemon off;"