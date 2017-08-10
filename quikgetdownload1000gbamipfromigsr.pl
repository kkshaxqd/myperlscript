#!/usr/bin/perl -w

use strict;

my $x1;
my $out="ftp1000gdownload".".txt";
my @temp;
for my $i (10..29){
$x1="igsr$i".".tsv";
open INFILE, "<$x1" or die "couldn't open $x1\n"; 
open OUTFILE, ">>$out" or die "couldn't open $out\n";  #这是每次都在后面写入
while(<INFILE>)
{
chomp;
@temp=split /\t/, $_;
if ($temp[0]=~/\.mapped\.ILLUMINA\.bwa\.\w+\.exome/)  # .mapped.ILLUMINA.bwa.CEU.exome.20120522.bam
{
print OUTFILE "$temp[0]\n" 
}
else{}
}
close INFILE;
close OUTFILE;
}

