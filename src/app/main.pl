use strict;

use lib '/usr/src/app';
use BookParser;
use BookDatabase; # Angry database setup.

# Get a hash of all: bookName => bookFullFilename in $some_dir
sub getBookList {
  my ($some_dir) = @_;
  
  # Find the txt files in the specified book directory  
  opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
  my @bookFiles = grep { /\.txt$/ && -f "$some_dir/$_" } readdir(DIR);

  my %bookInformation;

  while(my $myBook = shift @bookFiles){    
    my $bookName = removeExtension($myBook);
    
    $bookInformation{$bookName} = $some_dir . "/" . "$myBook";
  }

  return %bookInformation;
}

# We assume extension is 3 letters and a .
sub removeExtension {
  my ($bookName) = @_;
  chop($bookName);
  chop($bookName);
  chop($bookName);
  chop($bookName);
  return $bookName;
}

################################################
#         MAIN
###############################################

  my $waitingTime = 20; # Seconds
  print "Sleeping " . $waitingTime . " seconds\n";
  sleep $waitingTime;
  print "Starting script\n";

BookDatabase::setUp();

my %bookInfo = getBookList("/usr/src/data/test/multiple-files");
for(keys %bookInfo) {
  BookParser::importBook($_, $bookInfo{$_});
} # for