FROM debian:bookworm

RUN apt-get update -y && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-zip \
    curl \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY ./tools/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/wordpress_entrypoint.sh /wordpress_entrypoint.sh
RUN chmod +x /wordpress_entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["/wordpress_entrypoint.sh"]