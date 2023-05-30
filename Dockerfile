FROM perl:5.34

RUN apt-get update && apt-get install -y build-essential libmariadb-dev-compat libmariadb-dev
RUN cpan DBD::mysql

COPY ./src/app /usr/src/app
WORKDIR /usr/src/app

CMD [ "perl", "connect.pl" ]