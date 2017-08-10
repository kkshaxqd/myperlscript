#!usr/bin/perl -w
#NCBI人类全基因列表提取结果去重处理    有问题，这个不行。
#writer:zhangqsh        514079685@qq.com;2016-07-29;
use strict;
#$/="/^\s*$/";空行
$/=undef;
open FILE,'<', 'human_gene_annotion_clean20160729.txt'  or die "Can't open file:$!";
open FOUTC,'>', 'human_gene_annotion20160729_clean.txt' or die "Can't open file:$!";
my $fin=<FILE>;
my @splitresults=split(/\n/,$fin);
foreach  (@splitresults) 
	{
	my @fenzu=split(/\|/,$_);
	foreach $fen (@fenzu)
	{@unique = grep { ++$count{$fen} < 2 } @fenzu;
	foreach (@unique){
	my $a=$a."|".$_;
	}
	}
	print FOUTC "$a\n";
	}
	close FILE;
    close FOUTC;