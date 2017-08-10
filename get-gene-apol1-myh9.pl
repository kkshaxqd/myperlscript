#!usr/bin/perl -w
#求千人基因组中两个特定位置基因的中国人的信息
#writer:张桥石   514079685@qq.com;2016-08-14;
use strict;
$/=undef;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
my $dest_file1=$ARGV[2];   #想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";
open (FILOUT1, ">$dest_file1") || die "Could not read from $dest_file1, program halting.";

my $fin1=<FILE1>;
$fin1=~s/\n/@@@@/gm;
my @splitresults1=split(/@@@@/,$fin1);
#print FILOUT "#CHROM  POS     ID      REF     ALT     Allele Frequency\n";
#print FILOUT1 "#CHROM  POS     ID      REF     ALT     Allele Frequency\n";
foreach  my $f1 (@splitresults1) 
{
my @fenzu=split(/\t/,$f1);
if ($fenzu[1]=~/POS/){next;}
if($fenzu[1] > 36649056 && $fenzu[1]< 36663576 ) {print FILOUT "$f1\n";} 
if($fenzu[1] > 36677327 && $fenzu[1]< 36784063 ) {print FILOUT1 "$f1\n";} 
}
close FILE1;
close FILOUT;
close FILOUT1;