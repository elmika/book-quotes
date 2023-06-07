use strict;
use DBI;

package BookDatabase;
use Encode 'encode', 'decode';
use vars qw( $source_file $x);

my @words=();
my $dbh;

sub setUp {

  my $dsn = "DBI:mysql:database=mysql;host=mysql_container";
  my $username = "root";
  my $password = "mysecretpassword";
  my $options = {
     mysql_enable_utf8mb4 => 1,
     RaiseError => 1,
     PrintError => 0,
     AutoCommit => 1,
   };

  $dbh = DBI->connect($dsn, $username, $password, $options) 
    or die $DBI::errstr;

  my $sth = $dbh->prepare("CREATE DATABASE IF NOT EXISTS testdb");
  $sth->execute() or die $DBI::errstr;

  $sth = $dbh->prepare("USE testdb");
  $sth->execute() or die $DBI::errstr;

  $sth = $dbh->prepare("DROP TABLE IF EXISTS `words`;");
  $sth->execute() or die $DBI::errstr;


  $sth = $dbh->prepare("CREATE TABLE `words` (
  `word` varchar(50) NOT NULL,
  `source` varchar(50) NOT NULL default '',
  `offset` int(11) NOT NULL,
  KEY `word` (`word`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COMMENT='Only words';");
  $sth->execute() or die $DBI::errstr;

} 

sub insertWord {
    my ($word) = @_;
    
    $x++;
    push @words, $word;

    if($x%100==0){
      flushWords();
    }
}

sub setSourceBook {
	my ($myBook) = @_;

	print "\n"."Importing the book: ".$myBook."\n";
	$x=0;
	$source_file = $myBook;
}

sub flushWords {
    insert_db(@words);
    @words=();
    print ("x");
}

# Init dbh global variable with database connection to testdb
sub connect_db {

  my $dsn = "DBI:mysql:database=testdb;host=mysql_container";
  my $username = "root";
  my $password = "mysecretpassword";
  my $options = {
     mysql_enable_utf8mb4 => 1,
     RaiseError => 1,
     PrintError => 0,
     AutoCommit => 1,
   };

  $dbh = DBI->connect($dsn, $username, $password, $options) 
    or die $DBI::errstr;

  my $sth = $dbh->prepare("USE testdb");
  $sth->execute() or die $DBI::errstr;
}

# Closes dbh database connection
sub disconnect_db {
  flushWords();  # Persist buffer
  my $rc = $dbh->disconnect  
    or warn $dbh->errstr;
}

# Prerequisite: The db should be connected...
sub insert_db {
  
  my @wordList = @_;
  my $y=0;
  my $length = scalar @wordList;

  my $sth = $dbh->prepare("INSERT INTO words
              (word, source, offset)
               values
              (?, ?, ?)");
  
  
  while (my $myWord = shift @wordList){
    if(defined $myWord){ # Another hotly fixed safety net
      $y++;
      my $offset = $x+$y-$length;
      $sth->execute($myWord, $source_file, $offset) or die $DBI::errstr;
    }
  }
  $sth->finish();
  # $dbh->commit or die $DBI::errstr; 

}

1;