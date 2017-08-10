#!usr/bin/perl -w
#去重
#writer:张桥石   514079685@qq.com;2016-08-14;
use strict;
$/=undef;
my $filename=$ARGV[0];   #不用每次改名称，在perl 输入命令时改
my $dest_file=$ARGV[1];  #让perl命令第二个为输出的文件名
open (FILE, "<$filename") || die "Could not read from $filename, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";
my $fin=<FILE>;
my @splitresults=split(/\n/,$fin);
my %count;
foreach (@splitresults)
{
if(exists($count{$_})){next;}
else {$count{$_}=1; print FILOUT "$_\n"}
}
close FILE;
close FILOUT;