use strict;

package HTMLStrip;
use Encode 'encode', 'decode';
use base "HTML::Parser";
require '/usr/src/app/database.pl';

my $dbh;

BEGIN { # Needed to modify the text event of our parser... (Just a wild guess)
my @words=();

# This text event is triggered when our parser finds some text within the HTML.
sub text {
  my ($self, $text) = @_;

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
} #  BEGIN


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
  
  # New book.  
  setSourceBook($myBook);

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