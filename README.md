# Rescuing old code written in perl.

## Prerequisite

You need to have Docker installed.

## Setup

Containerized perl app and MySQL database:

![App Architecture](./doc/book-reader-architecture.png)


- Set up network
	
	`$docker network create book-network`

- Build, run and initialize MySQL container

	`docker run --network=book-network --name mysql_container -e MYSQL_ROOT_PASSWORD=mysecretpassword -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf -d mysql:latest`

	see ./data/testdb.sql for the sql to create the words table.

	```
		$docker exec -it mysql_container bash
		$mysql -uroot -pmysecretpassword
		mysql> CREATE DATABASE testdb;
		mysql> USE testdb;
		mysql> CREATE TABLE `words` (
		    ->   `word` varchar(50) NOT NULL,
		    ->   `source` varchar(50) NOT NULL default '',
		    ->   `offset` int(11) NOT NULL,
		    ->   KEY `word` (`word`)
		    -> ) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COMMENT='Only words';
		Query OK, 0 rows affected
		mysql> exit
		$exit
	```

- Build & run perl image

	```
		$docker build -t perl-app .

		$docker run --network=book-network -it --name perl_container perl-app
	```

	**Note:** This will run the parsing of PoeTraor.htm and introduce data into the database.
	**Additional Note:** This version of the parser is not optimised and will take some time.

## Books and Words

This is a project developped using perl in 2009.

It reads books in text format (As can be found for example in Project Gutemberg - https://www.gutenberg.org/), parses sentences and stores them in a mysql database. The format used in the relational databases is designed to query for sentences containing specific words. It is also handy to examine word frequency in different books.

## Sample Databases

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

Now performed within the perl container script.