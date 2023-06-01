use strict;
use DBI;

package HTMLStrip;
use base "HTML::Parser";
use vars qw( $source_file $x);

my $dbh;

BEGIN {
my @words=();

# This text event is triggered when our parser finds some text within the HTML.
sub text {
  my ($self, $text) = @_;
  my $word='';

# Take html tags out
  while(/<.+?>/){
      # take it out of the string - we need to do the matching again, as there are wild chars in there...
      s/<.+?>//;
  }
  
  connect_db();
  # Get the plain words - we grab composite words (with - only) as single words.
  while(/((\w|[-ÆÁÂÀÅÃÄÇÐÉÊÈËÍÎÌÏÑÓÔÒØÕÖÞÚÛÙÜÝáâæàåãäçéêèðëíîìïñóôòøõößþúûùüýÿ])+)/){
      # do something with $1
      $x++;
      $word = $1;
      $word =~ s/[^\x00-\x7F]//g; # Hot fix: Remove characters not supported by our database.
      # print $word."\t";
      if($x%100==0){
        insert_db(@words);
        @words=();
        print ("x");
      }else{
        push @words, $word;
      }
      # take it out of the string - note this works fine because $word contains NO special char...
      s/$word//;
  }
  disconnect_db();
  # print $_."\n"; # want to see the garbage ?
} # sub
} #  BEGIN

# Init dbh global variable with database connection to testdb
sub connect_db {

  my $dsn = "DBI:mysql:database=testdb;host=mysql_container";
  my $username = "root";
  my $password = "mysecretpassword";

  $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1 }) 
    or die $DBI::errstr;

  my $sth = $dbh->prepare("USE testdb");
  $sth->execute() or die $DBI::errstr;
}

# Closes dbh database connection
sub disconnect_db {

  # disconnect from the db.
  my $rc = $dbh->disconnect  or warn $dbh->errstr;
}

# Prerequisite: The db should be connected...
sub insert_db {
  
  my $myWord;
        
  my $sth = $dbh->prepare("INSERT INTO words
              (word, source, offset)
               values
              (?, ?, ?)");
  my $y=0;
  while ($myWord = shift){
    if(defined $myWord){ # Another hotly fixed safety net
      $y++;
      $sth->execute($myWord, $source_file, $x+$y-100) or die $DBI::errstr;
    }
  }
  $sth->finish();
  # $dbh->commit or die $DBI::errstr; 

}


sub getBookList {
  my ($some_dir) = @_;
  
  # Find the txt files in the specified book directory  
  opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
  my @htmlBooks = grep { /\.txt$/ && -f "$some_dir/$_" } readdir(DIR);

  return @htmlBooks;
}

################################################
#         MAIN
###############################################
my $book_directory="/usr/src/data";
my @htmlBooks = getBookList($book_directory);

while(my $myBook = shift @htmlBooks){
  my $p = new HTMLStrip;
  print "\n"."Importing the book: ".$myBook."\n";
  $x=0;
  $source_file = $myBook;
  # parse line-by-line, rather than the whole file at once
  #  Read the file
  open(my $in,  "<",  $book_directory."/".$myBook)  or die "Can't open $myBook: $!";
  # loop through the lines
  while (<$in>) {     # assigns each line in turn to $_
    $p->parse($_);
  }
  # flush and parse remaining unparsed HTML
  $p->eof;
} # while