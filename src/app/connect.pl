use DBI;

my $dsn = "DBI:mysql:database=testdb;host=mysql_container";
my $username = "root";
my $password = "mysecretpassword";

my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1 }) 
    or die $DBI::errstr;

print "Connected successfully";

$dbh->disconnect();