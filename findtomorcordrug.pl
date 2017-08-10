#! /usr/bin/perl -w
use strict;
my $x1 = $ARGV[0]; 
open INFILE1, "$x1" or die "couldn't open $x1\n";

while (<INFILE1>)
{
	 chomp;
	 if($_=~/Drugbank-id/){print "$_\n"}
	 elsif ($_=~/tumor|cancer|carcinoma|chemotherapy 
	 |leukemia|radiation|lymphoma|monoclonal\santibody
	 |metastatic|adenocarcinoma|mesothelioma|squamous/xi)
	 {print "$_\n"}
	 else{}
}
close INFILE1;
