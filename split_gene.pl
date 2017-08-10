#!/usr/bin/perl -w
use strict;
use warnings;

my $hg=shift;
open IN,"<",$hg or die $!;
print "#chrom\texonStarts\texonEnds\ttranscript_id\tgene_name\n";
while(<IN>){
	chomp;
	next if(/^#/);
	my @F=split;
	my @start=split /\,/,$F[9];
	my @end=split /\,/,$F[10];
	for (my $i=0;$i<@start;$i++){
	print "$F[2]\t$start[$i]\t$end[$i]\t$F[1]\t$F[12]\n";
	}
}
