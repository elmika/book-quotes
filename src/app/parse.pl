use strict;

package HTMLStrip;
use Encode 'encode', 'decode';
use base "HTML::Parser";
#require '/usr/src/app/database.pl';
use lib '/usr/src/app';
use BookDatabase;

BEGIN { # Needed to modify the text event of our parser... (Just a wild guess)  
  sub text { # This text event is triggered when our parser finds some text within the HTML.
    # my ($self, $text) = @_;
    extractWords($_);
  } # sub
} #  BEGIN

sub extractWords {
  my ($string) = @_;

  # Take html tags out
  while($string =~ /<.+?>/){
      # take it out of the string - we need to do the matching again, as there are wild chars in there...
      $string =~ s/<.+?>//;
  }

  while ($string =~ /((\p{L}|-)+)/g) {      
      my $word = $1;
      BookDatabase::insertWord($word);
      # take it out of the string
      $string =~ s/$word//;
  }  
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

# Fix encoding: ISO-8859-1 => Perl's internal format => UTF-8
sub ISO_to_UTF {
    my ($line) = @_;
    my $decoded_line = decode('ISO-8859-1', $line);
    my $utf8_line = encode('UTF-8', $decoded_line);

    return $utf8_line;
}

# Parse and import a book 
sub importBook {
  my ($myBook, $bookFilename) = @_;
  
  # New book.  
  BookDatabase::connect_db();
  BookDatabase::setSourceBook($myBook);

  # parse - line by line.
  my $p = new HTMLStrip;  
  # $p->parse_file($bookFilename);  
  open(my $in,  "<:encoding(ISO-8859-1)",  $bookFilename)  
    or die "Can't open $myBook: $!";
  while (<$in>) {
    my $line = ISO_to_UTF($_);
    $p->parse($line);
  }
  
  BookDatabase::disconnect_db();  
  $p->eof; # flush and parse remaining unparsed HTML
}

################################################
#         MAIN
###############################################

my %bookInfo = getBookList("/usr/src/data/test/multiple-files");
for(keys %bookInfo) {
  importBook($_, $bookInfo{$_});
} # for