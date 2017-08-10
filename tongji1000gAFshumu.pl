#!usr/bin/perl -w
#求千人基因组中两个特定位置基因的中国人的样本信息0|0  0|1   1|0  1|1统计
#writer:张桥石   514079685@qq.com;2016-08-14;
use strict;
$/=undef;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";
my $fin1=<FILE1>;
$fin1=~s/\n/@@@@/gm;
my @splitresults1=split(/@@@@/,$fin1);

foreach  my $f1 (@splitresults1) 
{
 my $countAA=0;
 my $countAF=0;
 my $countFA=0;
 my $countFF=0;
 my $sumcount=0;
    my @fenzu=split(/\t/,$f1);
     foreach my $fen (@fenzu)
     {
      if ($fen=~/0\|0/) {$countAA++;}
	  if ($fen=~/0\|1/) {$countAF++;}
	  if ($fen=~/1\|0/) {$countFA++;}
	  if ($fen=~/1\|1/) {$countFF++;}
     } 
	 $sumcount=$countAA+$countAF+$countFA+$countFF;
	 print FILOUT "sum:$sumcount,0|0:$countAA,0|1:$countAF,1|0:$countFA,1|1:$countFF\n";
}

close FILE1;
close FILOUT;
	 