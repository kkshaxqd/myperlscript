#!/usr/bin/env perl

#对XHMM输出结果进行处理转换，生成cnvscan能识别的输入文件。

use warnings;
use strict;

my $input=$ARGV[0];

my $output=$ARGV[1];

my (@hang,$cnvstate,$chr,$cnvstart,$cnvend,$cnvqual);

open INFILE, "<$input" or die "couldn't open $input\n"; 
open OUTFILE, ">$output" or die "the command line maybe like this: xhmmcnvconvertforcnvscan.pl DATA.xcnv DATA.forcnvscan.cnv \n";

#print OUTFILE "SAMPLE\tCNV\tINTERVAL\tKB\tCHR\tMID_BP\tTARGETS\tNUM_TARG\tQ_EXACT\tQ_SOME\tQ_NON_DIPLOID\tQ_START\tQ_STOP\tMEAN_RD\tMEAN_ORIG_RD\n";
while(<INFILE>){
chomp;
next if /^SAMPLE/;
@hang=split /\t/, $_;
if ($hang[1]=~/DEL/){$cnvstate=1}
elsif ($hang[1]=~/DUP/){$cnvstate=3}
#chr1:89476586-89477710
if ($hang[2]=~/chr(\S)\:(\d+)\-(\d+)/){$chr=$1;$cnvstart=$2;$cnvend=$3}   
if ($hang[10]){$cnvqual=$hang[10]}
print OUTFILE "$chr\t$cnvstart\t$cnvend\t$cnvstate\t$cnvqual\n"
}

close INFILE;
close OUTFILE;


