#!usr/bin/perl -w
#找到样本结果中外显子区或剪切区并非同义的突变 排序，去重
#writer:张桥石   514079685@qq.com;2016-08-14;
use strict;
$/=undef;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容

my $dest_file=$ARGV[1];  #第二个想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";

open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";

my $fin1=<FILE1>;
$fin1=~s/\n/@@@@/gm;
my @splitresults1=split(/@@@@/,$fin1);
my @temp1=();
foreach  my $f1 (@splitresults1) 
{ 
if ($f1=~/\t(\w*)\t\.\t(synonymous\sSNV)/) 
{next;}
else 
{
push (@temp1,$f1);   ####得到不包含同义突变的数组
}
}
my @temp2=();
foreach (@temp1)
{if ($_=~/\t(\w*)\t\.\t\w+/)
    {
     push (@temp2,$1);
    }
elsif ($_=~/\tsplicing\t(\w*)\t/)     #####得到所有有意义的突变里的基因
      {
      push (@temp2,$1);
      }
}

@temp2=sort(@temp2);          #######排序，去重
my %count;
foreach my $temp(@temp2) 
{
if( exists($count{$temp})){next;}
else {$count{$temp}=1; print FILOUT "$temp\n"}
}

close FILE1;

close FILOUT;