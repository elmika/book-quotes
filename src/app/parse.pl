use strict;
use DBI;

package HTMLStrip;
use Encode 'encode', 'decode';
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

  while ($string =~ /((\p{L}|-)+)/g) {      
      $word = $1;
      insertWord($word);      
      # take it out of the string
      $string =~ s/$word//;
  }  
}

  sub insertWord() {
    my ($word) = @_;
    
    $x++;
    push @words, $word;

    if($x%100==0){
      flushWords();
    }
  }

  sub flushWords() {
    insert_db(@words);
    @words=();
    print ("x");
  }
} #  BEGIN

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

  # disconnect from the db.
  my $rc = $dbh->disconnect  or warn $dbh->errstr;
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
  open(my $in,  "<:encoding(ISO-8859-1)",  $bookFilename)  or die "Can't open $myBook: $!";
  while (<$in>) {
    
    # Fix encoding
    my $line = $_;
    # Decode from ISO-8859-1 to Perl's internal format
    my $decoded_line = decode('ISO-8859-1', $line);
    # Encode from Perl's internal format to UTF-8
    my $utf8_line = encode('UTF-8', $decoded_line);

    # Parse
    $p->parse($utf8_line);
  }
  
  flushWords(); # persist remaining words
  $x=0; # reset offset for next book
  $p->eof; # flush and parse remaining unparsed HTML
}

################################################
#         MAIN
###############################################

#my %bookInfo = getBookList("/usr/src/data");
my %bookInfo = getBookList("/usr/src/data/test/one-hundred-and-few");
connect_db();
for(keys %bookInfo) {
  importBook($_, $bookInfo{$_});
} # for
disconnect_db();