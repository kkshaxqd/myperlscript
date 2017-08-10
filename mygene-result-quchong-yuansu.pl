#!usr/bin/perl -w
#NCBI人类全基因列表提取结果经R处理后去行内重复元素处理     ##这就行了                    
#writer:zhangqsh        514079685@qq.com;2016-07-29;
use strict;
#$/="/^\s*$/";空行
$/=undef;
open FILE,'<', 'human_gene_annotion_clean2016073015.txt'  or die "Can't open file:$!";  ###刚出来的文档，基因名\t后面的|最好不要先去掉，这样按|来去重才能成功
open FOUTC,'>', 'human_gene_annotion_clean2016073015_clean.txt' or die "Can't open file:$!";
my $fin=<FILE>;
$fin=~s/\n/@@@@/gm;
my @splitresults=split(/@@@@/,$fin);
foreach  (@splitresults) 
{
my @neifen=split(/\|/,$_);  ###对每行中的元素按|分组
my @new=();                 ###每次清空数组
my $temp="";             
foreach my $a (@neifen) 
 { if ($a=~/Unknown/)
    {push @new ,$a;}
else	
  { 
    if(not $temp eq $a)     ####如果不等就放到数组new里，然后
     {
        push @new,$a;
        $temp = $a;
     }
  }                            ###得到将所有元素加进去的@new
 }
 my $newhang=join("|",@new);	 ###join函数不是新加进去吧。。。每次循环$newhang会被重新指定吧
 print FOUTC "$newhang\n";
}
close FILE;
close FOUTC;