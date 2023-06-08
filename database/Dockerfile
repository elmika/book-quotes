FROM mysql:latest

COPY ./my.cnf /etc/mysql/conf.d/
COPY ./init/testdb.sql /docker-entrypoint-initdb.d/0-testdb.sql
COPY ./init/create-backup-databases.sh /docker-entrypoint-initdb.d/1-create-backup-databases.sh
COPY ./backups/sun_tzu.sql /docker-entrypoint-initdb.d/2-sun_tzu.sql
COPY ./backups/sample_books.sql /docker-entrypoint-initdb.d/3-sample_books.sql
