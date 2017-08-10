#!usr/bin/perl -w
#NCBI人类全基因列表提取
#writer:zhangqsh        514079685@qq.com;2016-07-22;
use strict;
#$/="/^\s*$/";空行
$/=undef;
open FILE,'<', 'gene_result.txt'  or die "Can't open file:$!";
open FOUTC,'>', 'humangene_list.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my @splitresults=split(/ABQ/,$fin);
my $count=0;
my $sum=0;
foreach  (@splitresults) 
	{
	if ($_=~/^\d*\.\s(.*)/mg)
	{print FOUTC "$1\n";
	}
	}
close FILE;
close FOUTC;