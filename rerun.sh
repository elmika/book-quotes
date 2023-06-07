docker rm perl_container
docker build -t perl-app src
docker-compose up --build app
#docker run --network=book-network -it --name perl_container perl-app
