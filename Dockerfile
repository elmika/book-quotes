FROM perl:5.34
COPY ./src/app /usr/src/app
WORKDIR /usr/src/app
CMD [ "perl", "hello.pl" ]