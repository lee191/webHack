FROM mariadb:latest

ENV MARIADB_ROOT_PASSWORD=root
ENV MARIADB_DATABASE=my_database

COPY init.sql /docker-entrypoint-initdb.d/
