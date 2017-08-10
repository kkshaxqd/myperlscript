#!usr/bin/perl -w
#筛选关键词是癌症和药物的数据
#writer:zhangqsh@gentalker.com;2016-04-01;
use strict;
$/=undef;
open FILE,'<', '8875shuru.txt'  or die "Can't open file:$!";
open FOUTC,'>', 'completed-cancer-drug-data.txt' or die "Can't open file:$!";
open FOUTDRUG,'>', 'drug-mingcheng-data.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my @splitresults=split(/ABQ/,$fin);
my $count=0;
my $sum=0;
foreach  (@splitresults) 
	{
	if ($_=~/Completed/mg)
		{
	     if ($_=~/cancer|Carcinom\w|tumo\w+|neoplasm|CLL|Leukemia|lymph\w+|angiomyolipoma/img) 
			 {
			 if ($_=~/Drug:(.{0,30})/img) {
				   
				   print FOUTC "The number is ".("$sum"+1);
                   print FOUTC "$_\n";
				   print FOUTDRUG "Drug: $1\n";
		           $sum++;
		  }
	   }
	}
}
print FOUTC "The total number is $sum.\n";
print FOUTDRUG "The total number is $sum.\n";

close FILE;
close FOUTC;

close FOUTDRUG;