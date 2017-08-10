#!usr/bin/perl -w
#NCBI人类全基因列表提取结果经R处理后去|处理                      
#writer:zhangqsh        514079685@qq.com;2016-07-29;
use strict;
#$/="/^\s*$/";空行
$/=undef;
#open FILE,'<', 'human_gene_annotion_clean2016073008.txt'  or die "Can't open file:$!";
open FILE,'<', 'human_gene_annotion_clean2016073015_clean.txt'  or die "Can't open file:$!";
open FOUTC,'>', 'human_gene_annotion_clean2016073015_clean_clean.txt' or die "Can't open file:$!";
my $fin=<FILE>;
$fin=~s/\n/@@@@/gm;
my @splitresults=split(/@@@@/,$fin);
foreach  (@splitresults) 
	{
	$_=~s/\t\|/\t/g;             ###全局替换   这样结果就符合了。完全！！！多余的|的特征不是空格后|，而是制表符后|
	print FOUTC "$_\n";
	}
close FILE;
close FOUTC;
