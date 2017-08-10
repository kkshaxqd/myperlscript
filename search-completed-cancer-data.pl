#!usr/bin/perl -w
#筛选关键词是干扰素和癌症的数据
#writer:zhangqsh@gentalker.com;2016-03-29;
use strict;
$/=undef;
open FILE,'<', 'completed.txt'  or die "Can't open file:$!";
open FOUTC,'>', 'completed-nointerferon-cancer-data.txt' or die "Can't open file:$!";
open FOUTI,'>', 'interferon-cancer-data.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my @splitresults=split(/ABQ/,$fin);
my $count=0;
my $sum=0;
foreach  (@splitresults) {
	
	if ($_=~/cancer|Carcinoma|tumo\w+|neoplasm/img) {
		if ($_=~/interf\w+|IFN|\bIL|interleukin|oprelvekin/img) {
        print FOUTI "$_\n";
		$sum++;}
		else{
			print FOUTC "$_\n";
		$count++;
		}
	}
}
print FOUTI "The total number is $sum.\n";
print FOUTC "The total number is $count.\n";
close FILE;
close FOUTC;
close FOUTI;
