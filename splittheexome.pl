#!/usr/bin/perl -w

#分析DMD基因的测序深度然后，确定判断是否有CNV缺失情况
#包含每个外显子区域前后50bp左右位置的测序深度，首先使用samtools depth -a -b bed文件，外显子区域起始和结束  -f bam文件list > 输出。
#1bed文件好像只是根据第二列和第三列，起始终止位置，然后计算起始和终止之间全部区域的reads数。 所以，首先需要把bed文件处理下，HGMD中DMD基因
#NM号是NM_004006  ，处理这个转录本的外显子区域。这个是之前的处理。

use strict;

my $input=$ARGV[0];

my $output=$ARGV[1];

my (@DMDzong,@DMDexomestart,@DMDexomeend,$exomeid);

open INFILE, "<$input" or die "couldn't open $input\n"; 
open OUTFILE, ">$output" or die "couldn't open $output\n";

while(<INFILE>){
chomp;
next if /^#/;
@DMDzong=split /\t/, $_;
if ($DMDzong[6]){
@DMDexomestart=split /,/,$DMDzong[6];
@DMDexomeend=split /,/,$DMDzong[7];
}
for my $i (0..$#DMDexomestart){    #或者@DMDexomestart-1 也是同样的意思

$exomeid=$i+1;
print OUTFILE "chrX\t$DMDexomestart[$i]\t$DMDexomeend[$i]\t$exomeid\n";

}
}

close INFILE;
close OUTFILE