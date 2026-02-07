FROM debian:bookworm

RUN apt-get update -y && apt-get install mariadb-server -y

RUN mkdir -p /run/mysqld /tmp && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /tmp && \
    chmod 755 /tmp

COPY ./tools/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/mariadb_entrypoint.sh /

RUN chmod +x /mariadb_entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/mariadb_entrypoint.sh"]