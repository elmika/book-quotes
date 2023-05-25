# Rescuing old code written in perl.

## Simple tests

- `hello.pl` Hello world!
- `argv.pl` Test command line input

## Books and Words

This is a project developped using perl in 2009.

It reads books in text format (As can be found for example in Project Gutemberg - https://www.gutenberg.org/), parses sentences and stores them in a mysql database. The format used in the relational databases is designed to query for sentences containing specific words. It is also handy to examine word frequency in different books.

## Sample Database

### Load sample database

A sample database is available in the file testdb.sql

To load this database using Docker:

- Run a docker mysql container:


	`$docker run -p 3306:3306 -d --name mysql -e MYSQL_ROOT_PASSWORD=password mysql/mysql-server`
	
- Copy the testdb.sql file into the container:


	`$docker cp ./testdb.sql mysql:/`
	
- Enter the container to access the database and create the testdb database:


	```
		$docker exec -it mysql bash
		$mysql -uroot -ppassword
		mysql>create database testdb;
		mysql>exit
	```
	
- Load the file:


	`$mysql -uroot -p testdb -ppassword < /testdb.sql`
	

The data is now available.


### Load other sample database

Perform the same steps with the `testdb-original.sql` database export and the `testdb_original` database.


### Explore information stored

A few sql scripts have been provided. Feel free to run them in the command line to see sentences extracted from our book databases.

- known sources in testdb: 

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

- known sources in testdb_original: 


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

*Note: Because of the above, everything is dumped into the root folder... As is.*

**First test:** We read an extract of "Histoires Extraordinaires", the translation of E.A. Poe by Charles Beaudelaire, and display it on the screen.

To execute, run:

`$perl hola.pl`
