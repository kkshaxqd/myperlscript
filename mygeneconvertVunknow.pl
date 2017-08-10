#!usr/bin/perl -w
#mygene结果改成id 对应 term,pubmed,evidence的形式。
#writer:zhangqsh        514079685@qq.com;2016-07-22;
use strict;
$/=undef;
open FILE,'<', 'humangenegobp.txt'  or die "Can't open file:$!";  #  文件格式为query go.BP go.CC go.MF pathway.kegg pathway.reactome pathway.pharmgkb
open FOUTC,'>', 'gobp_conver.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/\n$/@@@@@@@@@@@@@@@/gm;
my @splitresults=split(/@@@@@@@@@@@@@@@/,$fin);
my @genename;
my @id;
my @term;
my @pubmed;
my @evidence;
# 得到基因名称的数组
foreach (@splitresults)	{
if ($_=~/^(\w*)\s/mg)
	{
	push @genename "$1";
	}
}#得到基因的所有id,数组
foreach (@splitresults)	{

if ($_=~/list\(id\s=\sc\(\"(GO:\d*)\,/mg)
{
push @id "$1";
}
}
#得到基因的所有term
foreach (@splitresults){
if ($_=~//mg)


}
