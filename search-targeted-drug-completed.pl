#!usr/bin/perl -w
#筛选关键词是癌症靶向药的数据
#writer:zhangqsh@gentalker.com;2016-03-30;
use strict;
$/=undef;
open FILE,'<', 'completed-cancer-data.txt'  or die "Can't open file:$!";
open FOUT,'>', 'completed-cancer-drug-data.txt' or die "Can't open file:$!";
open FOUTDRUG,'>', 'targeted-cancer-drug-sum.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my $count=0;
my @splitresults=split(/ABQ/,$fin);
foreach  (@splitresults) {
	if ($_=~/Drug:(.*)/img) {
		print FOUT "$_\n";
		$count++;
		print FOUTDRUG "Drug: $1\n";
	}
}
print FOUT "The number is $count.\n";
close FILE;
close FOUT;
close FOUTDRUG;
