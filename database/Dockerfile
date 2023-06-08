FROM mysql:latest

COPY ./my.cnf /etc/mysql/conf.d/
COPY ./init/testdb.sql /docker-entrypoint-initdb.d
