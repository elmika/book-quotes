use strict;
use DBI;

package HTMLStrip;
use base "HTML::Parser";

BEGIN {
my $x=0;
my @words=();

sub text {
  my ($self, $text) = @_;
  my $word='';

 # Take html tags out
  while(/<.+?>/){
      # take it out of the string - we need to do the matching again, as there are wild chars in there...
      s/<.+?>//;
  }
  # Get the plain words - default behaviour is the matching source string is $_ Eh... Where does it come from again ??
  while(/((\w|[ÆÁÂÀÅÃÄÇÐÉÊÈËÍÎÌÏÑÓÔÒØÕÖÞÚÛÙÜÝáâæàåãäçéêèðëíîìïñóôòøõößþúûùüýÿ])+)/){
      # do something with $1
      $x++;
      $word = $1;
      $word =~ s/[^\x00-\x7F]//g; # Hot fix: Remove characters not supported by our database.
      # print $word."\t";
      if($x==100){
        insert_db(@words);
        @words=();
        print ($x."\t");
        $x=0;
      }else{
        push @words, $word;
      }
      # take it out of the string
      s/$word//;
  }
  print ($x."\t");
} # sub
} #  BEGIN


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
                          (?)");
  while ($myWord = shift){
    if(defined $myWord){
      $sth->execute($myWord) or die $DBI::errstr;
    }    
  }
  $sth->execute() or die $DBI::errstr;
  $sth->finish();
  # $dbh->commit or die $DBI::errstr;
  # disconnect from the db.
  my $rc = $dbh->disconnect  or warn $dbh->errstr;  

}
################################################
#         MAIN
###############################################
# grab the html files in the ebooks directory
my $some_dir="/usr/src/data";
opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
my @htmlBooks = grep { /\.txt$/ && -f "$some_dir/$_" } readdir(DIR);

while(my $myBook = shift @htmlBooks){
  my $p = new HTMLStrip;
  print "\n"."Importing the book: ".$myBook."\n";
  # parse line-by-line, rather than the whole file at once
  #  Read the file
  open(my $in,  "<",  $some_dir."/".$myBook)  or die "Can't open $myBook: $!";
  # loop through the lines
  while (<$in>) {     # assigns each line in turn to $_
    $p->parse($_);
  }
  # flush and parse remaining unparsed HTML
  $p->eof;
} # while