#!/usr/bin/perl -w
####修改者，张桥石，514079685@qq.com 2016-10-27#####
###########################
####对iTools得到的Q20Q30结果文档进行处理，得到想要的数据。
####解决思路，这个文件行数和样本数想要得到的行都是有规律的，比如第一行是样本1R1，第145行是样本1R2,没144行一个重复，这个并不行。其中间有些事有40-50的，但foreach匹配每次都匹配多。
use strict;

$/=undef;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";
my $fin1=<FILE1>;
# my $hangshu=0;
# while(<FILE1>){$hangshu++;}       ####行数
#my $fastqgzshu=$hangshu/144;      ####fastq.gz数
#my $yangbenshu=$hangshu/288;      ####样本数

$fin1=~s/^125.*\n/@@@@/gm;   ####这样替换把想分析的那部分拿出来做一块单独放到一个元素中...原来这么简单，我折腾了那么久。还是要先找好规律，不用必须按行来分，按块来分也可以哒。
my @splitresults1=split(/@@@@/,$fin1); 

my $col_name= "Sample_ID"."\t"."Q20_base_number"."\t"."Q30_base_number"."\t"."Total_base_number"."\t"."Q20\(\%\)"."\t"."Q30\(\%\)"."\t"."average_Q20\(\%\)"."\t"."average_Q30\(\%\)";
print FILOUT "$col_name\n";




foreach  (@splitresults1){
my $a=0;
my $zongbasenumber=0;
my $q20q30jianbili=0;
my $q20q30jianbasenumber=0;
my $q30yishangbasenumber=0;
my $q30yishangbili=0;
my $q20basenumber=0;
my $dayuq20=0;
my $dayuq30=0;
my $hang_neirong=0;
my $q40yishangbasenumber=0;
my $q40yishangbili=0;
if ($_=~/\#\#(.*)\#\#/){$a=$1;}
if ($_=~/\#ReadNum\:\s(\d*)\sBaseNum\:\s(\d*)\sReadLeng/){$zongbasenumber=$2;}
if ($_=~/\#BaseQ\:20\-\-30\s\:\s(.*)\((.*)\%\)/){$q20q30jianbasenumber=$1;$q20q30jianbili=$2;}
if ($_=~/\#BaseQ\:30\-\-40\s\:\s(.*)\((.*)\%\)/){$q30yishangbasenumber=$1;$q30yishangbili=$2;}
if ($_=~/\#BaseQ\:40\-\-50\s\:\s(.*)\((.*)\%\)/){$q40yishangbasenumber=$1;$q40yishangbili=$2;}
   $q20basenumber=$q20q30jianbasenumber+$q30yishangbasenumber+$q40yishangbasenumber;
   $q30yishangbasenumber=$q30yishangbasenumber+$q40yishangbasenumber;   
   $dayuq20=$q20q30jianbili+$q30yishangbili+$q40yishangbili; 
   $dayuq30=$q30yishangbili+$q40yishangbili;
   $hang_neirong= "$a"."\t"."$q20basenumber"."\t"."$q30yishangbasenumber"."\t"."$zongbasenumber"."\t"."$dayuq20"."\t"."$dayuq30";
   print FILOUT "$hang_neirong\n";
}


close FILE1;
close FILOUT;









