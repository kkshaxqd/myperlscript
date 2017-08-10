#!/usr/bin/perl -w
####修改者，张桥石，514079685@qq.com 2016-10-27#####
###########################
####对iTools得到的Q20Q30结果文档进行第一步处理后，进行第二步处理，求每对样本平均的Q20Q30。
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

my $col_name= "Sample_ID"."\t"."Q20_base_number"."\t"."Q30_base_number"."\t"."Total_base_number"."\t"."Q20\(\%\)"."\t"."Q30\(\%\)"."\t"."average_Q20\(\%\)"."\t"."average_Q30\(\%\)";
print FILOUT "$col_name\n";

$fin1=~s/\n/@@@@/gm;
my @splitresults1=split(/@@@@/,$fin1); 
my $splitresults1=@splitresults1;
print $splitresults1;

my $R1a=0;
my $R1zongbasenumber=0;
my $R1q20basenumber=0;
my $R1q20bili=0;
my $R1q30basenumber=0;
my $R1q30bili=0;
my $average_q20=0;
my $average_q30=0;

my $R2a=0;
my $R2zongbasenumber=0;
my $R2q20basenumber=0;
my $R2q20bili=0;
my $R2q30basenumber=0;
my $R2q30bili=0;


my $R1nei_rong=0;
my $R2nei_rong=0;
####WGC045799U_combined_R2.fastq.gz    5961076605      5695230656      6245639000      95.45   91.19
####printf ("%4.2f", $aver_Q20); printf "\t"; printf ("%4.2f",$aver_Q30); printf "\n";
foreach  (@splitresults1){
if ($_=~/(WGC.*R1\.fastq\.gz)\t(\S*)\t(\S*)\t(\S*)\t(\S*)\t(\S*)/){$R1a=$1;$R1q20basenumber=$2;$R1q30basenumber=$3;$R1zongbasenumber=$4; $R1q20bili=$5; $R1q30bili=$6;}
if ($_=~/(WGC.*R2\.fastq\.gz)\t(\S*)\t(\S*)\t(\S*)\t(\S*)\t(\S*)/){$R2a=$1;$R2q20basenumber=$2;$R2q30basenumber=$3;$R2zongbasenumber=$4; $R2q20bili=$5; $R2q30bili=$6;
 $R1nei_rong="$R1a,$R2a"."\t"."$R1q20basenumber"."\t"."$R1q30basenumber"."\t"."$R1zongbasenumber"."\t"."$R1q20bili"."\t"."$R1q30bili"."\n"; 
 print FILOUT "$R1nei_rong";
 $average_q20=($R1q20bili+$R2q20bili)/2;
 $average_q30=($R1q30bili+$R2q30bili)/2;
 #$R2nei_rong="$R2a"."\t"."$R2q20basenumber"."\t"."$R2q30basenumber"."\t"."$R2zongbasenumber"."\t"."$R2q20bili"."\t"."$R2q30bili"."\t"."$average_q20"."\t"."$average_q30"."\n";
 print FILOUT "\t"."$R2q20basenumber"."\t"."$R2q30basenumber"."\t"."$R2zongbasenumber"."\t"."$R2q20bili"."\t"."$R2q30bili"."\t"; printf FILOUT ("%4.2f", $average_q20);printf FILOUT "\t"; printf FILOUT ("%4.2f",$average_q30); printf FILOUT "\n";}
}

close FILE1;
close FILOUT;