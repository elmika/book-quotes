docker rm perl_container
docker build -t perl-app .
docker run --network=book-network -it --name perl_container perl-app
