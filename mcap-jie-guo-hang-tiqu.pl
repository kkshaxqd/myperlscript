#!/usr/bin/perl -w
####修改者，张桥石，514079685@qq.com 2016-11-01#####

use strict;

$/=undef;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";
my $fin1=<FILE1>;


$fin1=~s/\n/@@@@/gm;   
my @splitresults1=split(/@@@@/,$fin1); 
foreach (@splitresults1)
{
if ($_=~/esp6500si_all/){ print FILOUT "$_\n"; }
else{ my @new=split "\t",$_;
		if ($new[52])
		{
		if($new[52]>0.025)
			{
			print FILOUT "$_\n";
			}
		}
	}
}
close FILE1;
close FILOUT;
