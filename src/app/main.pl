use strict;

use lib '/usr/src/app';
use BookParser;
# require '/usr/src/app/parse.pl';

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

################################################
#         MAIN
###############################################

my %bookInfo = getBookList("/usr/src/data/test/multiple-files");
for(keys %bookInfo) {
  BookParser::importBook($_, $bookInfo{$_});
} # for