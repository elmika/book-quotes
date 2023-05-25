#!C:\apache2triad\perl\bin\perl.exe
use strict;

package HTMLStrip;
use base "HTML::Parser";

sub text {
  my ($self, $text) = @_;
  print $text;
}

my $p = new HTMLStrip;
# parse line-by-line, rather than the whole file at once
#  Read the file
open(my $in,  "<",  "PoeTraor.htm")  or die "Can't open input.txt: $!";
# loop through the lines
while (<$in>) {     # assigns each line in turn to $_
  $p->parse($_);
}
# flush and parse remaining unparsed HTML
$p->eof;