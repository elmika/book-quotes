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

## Book Parser

// Upcoming
