#!usr/bin/perl -w
#筛选临床期间的血液病。
#writer:zhangqsh@gentalker.com;2016-04-01;
use strict;
$/=undef;
open FILE,'<', 'completed.txt'  or die "Can't open file:$!";
open FOUT,'>', 'cll-drug.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my $count=0;
my @splitresults=split(/ABQ/,$fin);
foreach  (@splitresults) {
	if ($_=~/leukemia|CLL/mg) {
		print FOUT "$_\n";
		$count++;
	}
}
print FOUT "The number is $count.\n";
close FILE;
close FOUT;