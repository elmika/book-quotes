# Rescuing old code written in perl.

## Prerequisite

You need to have Docker installed.

## Containerized perl app and MySQL database

- Set up network
	
	`$docker network create book-network`

- Build, run and initialize MySQL container

	`docker run --network=book-network --name mysql_container -e MYSQL_ROOT_PASSWORD=mysecretpassword -d mysql:latest`


	```
		$docker exec -it mysql_container bash
		$mysql -uroot -pmysecretpassword
		mysql>create database testdb;
		mysql>
		$exit
	```

- Build & run perl image

	```
		$docker build -t perl-app .

		$docker run --network=book-network -it --name perl_container perl-app
	```

## Books and Words

This is a project developped using perl in 2009.

It reads books in text format (As can be found for example in Project Gutemberg - https://www.gutenberg.org/), parses sentences and stores them in a mysql database. The format used in the relational databases is designed to query for sentences containing specific words. It is also handy to examine word frequency in different books.

## Sample Database

### Load sample database

A sample database is available in the file sample_books.sql
	
- Copy the testdb.sql file into the mysql container & load the file:

	`$docker cp ./data/testdb.sql mysql_container:/`

	`$mysql -uroot -p testdb -pmysecretpassword < /sample_books.sql`
	

The data is now available.


### Load other sample database

Create `sun_tzu` database in the mysql container and upload the `sun_tzu.sql` data, as we did previously with `sample_books` and `sample_books.sql`.

### Explore information stored

A few sql scripts have been provided. Feel free to run them in the command line to see sentences extracted from our book databases.

- known sources in sample_books: 

```
mysql> SELECT source FROM sentences GROUP BY source;

+----------------+
| source         |
+----------------+
| atest.txt      |
| es_quijote.txt |
| en_quijote.txt |
| alice_EN.txt   |
| alice_FR.txt   |
+----------------+
```

- known sources in sun_tzu: 


```
mysql> SELECT source FROM words GROUP BY source;`

+------------------------------+
| source                       |
+------------------------------+
| sun_tzu_art_de_la_guerre.txt |
+------------------------------+
```

## Book Parser

*These are extracts of the code as I found them, restored in a format that runs, and enhanced with this very readme so that they can be used without further investigation. Refactors and other improvements will be performed once we close this history branch.*

### Read through a large file

**Prerequisite:** You need to have perl installed on local.

We read the complete book "Histoires Extraordinaires", extract each word, and print it on screen.

To execute, run:

`$perl src/app/parse.pl`