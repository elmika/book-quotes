#!C:\apache2triad\perl\bin\perl.exe
print "HOLA MUNDO!\n";

#  Read the file
open(my $in,  "<",  "shortPoeTraor.htm")  or die "Can't open input.txt: $!";
my $word;
# loop through the lines
while (<$in>) {     # assigns each line in turn to $_
        print "Just read in this line: $_";
		# while there is a word in that line
		while(/(\w+)/){
			# do something with $1
			$word = $1;
			print "found a word : ".$word."\n";
			# take it out of the string
			s/$word//;
		}
}
exit(1);

