use strict;
use DBI;

package HTMLStrip;
use base "HTML::Parser";
use vars qw( $source_file $x);

my $dbh;

BEGIN { # Needed to modify the text event of our parser... (Just a wild guess)
my @words=();

# This text event is triggered when our parser finds some text within the HTML.
sub text {
  my ($self, $text) = @_;

  # select * from words where offset > 2350 order by offset asc limit 25;
  extractWords($_);

} # sub

sub extractWords {
  my ($string) = @_;
  my $word='';

  # Take html tags out
  while($string =~ /<.+?>/){
      # take it out of the string - we need to do the matching again, as there are wild chars in there...
      $string =~ s/<.+?>//;
  }

  # Get the plain words - we grab composite words (with - only) as single words.
  while($string =~ /((\w|[-ÆÁÂÀÅÃÄÇÐÉÊÈËÍÎÌÏÑÓÔÒØÕÖÞÚÛÙÜÝáâæàåãäçéêèðëíîìïñóôòøõößþúûùüýÿ])+)/){
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
      $string =~ s/$word//;
  }
}
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


# Get a hash of all: bookName => bookFullFilename in $some_dir
sub getBookList {
  my ($some_dir) = @_;
  
  # Find the txt files in the specified book directory  
  opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
  my @bookFiles = grep { /\.txt$/ && -f "$some_dir/$_" } readdir(DIR);

  my %bookInformation;

  while(my $myBook = shift @bookFiles){    
    my $bookName = $myBook;
    # strip .txt
    chop($bookName);chop($bookName);chop($bookName);chop($bookName);
    
    $bookInformation{$bookName} = $some_dir . "/" . "$myBook";
  }

  return %bookInformation;
}

# Parse and import a book 
sub importBook {
  my ($myBook, $bookFilename) = @_;
  
  print "\n"."Importing the book: ".$myBook."\n";
  
  # Init global variables for new book.
  $x=0;
  $source_file = $myBook;

  # parse - line by line.
  my $p = new HTMLStrip;
  # $p->parse_file($bookFilename);  
  open(my $in,  "<",  $bookFilename)  or die "Can't open $myBook: $!";
  while (<$in>) {
    $p->parse($_);
  }
  
  $p->eof; # flush and parse remaining unparsed HTML
}

################################################
#         MAIN
###############################################

my %bookInfo = getBookList("/usr/src/data");
connect_db();
for(keys %bookInfo) {
  importBook($_, $bookInfo{$_});
} # for
disconnect_db();