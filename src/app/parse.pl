#!C:\apache2triad\perl\bin\perl.exe
use strict;
use DBI;

package HTMLStrip;
use base "HTML::Parser";

sub text {
  my ($self, $text) = @_;
  my $word='';
  while(/(\w+)/){
      # do something with $1
      $word = $1;
      # print $word."\t";
      insert_db($word);
      # take it out of the string
      s/$word//;
  }
}

sub insert_db {
  
  my $myWord = shift;
  
  my $dsn = "DBI:mysql:database=testdb;host=mysql_container";
  my $username = "root";
  my $password = "mysecretpassword";

  my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1 }) 
    or die $DBI::errstr;

  my $sth = $dbh->prepare("USE testdb");
  $sth->execute() or die $DBI::errstr;      
        
  $sth = $dbh->prepare("INSERT INTO words
                          (word)
                           values
                          ('$myWord')");
  $sth->execute() or die $DBI::errstr;
  $sth->finish();
  # $dbh->commit or die $DBI::errstr;
  # disconnect from the db.
  my $rc = $dbh->disconnect  or warn $dbh->errstr;
  print ("a");

}

my $p = new HTMLStrip;
# parse line-by-line, rather than the whole file at once
#  Read the file
open(my $in,  "<",  "./data/PoeTraor.htm")  or die "Can't open input.txt: $!";
# loop through the lines
while (<$in>) {     # assigns each line in turn to $_
  $p->parse($_);
}
# flush and parse remaining unparsed HTML
$p->eof;
