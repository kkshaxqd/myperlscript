#!usr/bin/perl -w
#求两个基因文件中的交集并去重
#writer:张桥石   514079685@qq.com;2016-08-14;
use strict;
$/=undef;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $filename2=$ARGV[1];  #第二个输入的文件名内容
my $dest_file=$ARGV[2];  #想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";
open (FILE2, "<$filename2") || die "Could not read from $filename2, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";

my $fin1=<FILE1>;
$fin1=~s/\n/@@@@/gm;
my @splitresults1=split(/@@@@/,$fin1);

my $fin2=<FILE2>;
$fin2=~s/\n/@@@@/gm;
my @splitresults2=split(/@@@@/,$fin2);

my @temp=();

foreach  my $f1 (@splitresults1) 
{ 
  foreach my $f2 (@splitresults2)
  {if ($f1 eq $f2) 
    {push (@temp,$f1);
	}
  }
}
my %count;
foreach my $temp(@temp) 
{
if( exists($count{$temp})){next;}
else {$count{$temp}=1; print FILOUT "$temp\n"}
}

close FILE1;
close FILE2;
close FILOUT;

