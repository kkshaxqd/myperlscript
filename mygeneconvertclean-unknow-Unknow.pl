#!usr/bin/perl -w
#NCBI人类全基因列表提取结果经R处理后将unknow变成Unkonwn处理                      
#writer:zhangqsh        514079685@qq.com;2016-07-29;
use strict;
#$/="/^\s*$/";空行
$/=undef;
open FILE,'<', 'human_gene_annotion20160730new_cleanchongfu.txt'  or die "Can't open file:$!";
open FOUTC,'>', 'human_gene_annotion20160730-last.txt' or die "Can't open file:$!";
my $fin=<FILE>;
$fin=~s/\n/@@@@/gm;
my @splitresults=split(/@@@@/,$fin);
foreach  (@splitresults) 
	{
	$_=~s/unknow/Unknown/g;             ###全局替换   这样结果就符合了。完全！！！多余的|的特征不是空格后|，而是制表符后|
	print FOUTC "$_\n";
	}
close FILE;
close FOUTC;
