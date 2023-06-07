FROM perl:5.34

RUN apt-get update && apt-get install -y build-essential libmariadb-dev-compat libmariadb-dev
RUN cpan DBD::mysql
RUN cpan HTML::Parser

COPY ./src /usr/src
WORKDIR /usr/src

CMD [ "perl", "app/main.pl" ]