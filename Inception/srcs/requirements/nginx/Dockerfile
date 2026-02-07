FROM debian:bookworm

RUN apt-get update -y && apt-get install -y \
    nginx \
    openssl \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY ./tools/nginx_entrypoint.sh /nginx_entrypoint.sh
RUN chmod +x /nginx_entrypoint.sh

EXPOSE 443
ENTRYPOINT [ "/nginx_entrypoint.sh" ]
