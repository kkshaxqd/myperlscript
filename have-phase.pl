#!usr/bin/perl -w
#筛选临床期间的癌症靶向新药或旧药有新治疗目标，根据观察发现完成的研究phases都是空的，正在研究的有进行到第几期。
#writer:zhangqsh@gentalker.com;2016-04-01;
use strict;
$/=undef;
open FILE,'<', 'completed-cancer-drug-data.txt'  or die "Can't open file:$!";
open FOUT,'>', 'targeted-clinical-phases-cancer-drug.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my $count=0;
my @splitresults=split(/ABQ/,$fin);
foreach  (@splitresults) {
	if ($_=~/Phase\s\d/img) {
		print FOUT "$_\n";
		$count++;
	}
}
print FOUT "The number is $count.\n";
close FILE;
close FOUT;