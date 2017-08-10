#! /usr/bin/perl -w
use strict;
use warnings;

my $read = $ARGV[0];
my $out1=$ARGV[1];
my $out2=$ARGV[2];
open INFILE1, "<$read" or die "couldn't open list_test\n";
open OUT1, ">$out1";
open OUT2, ">$out2";
while(<INFILE1>){
chomp;
if ($_=~/^\d+/){
print OUT1 "$_\n" ;}
else {
print OUT2 "$_\n" ;}

}

close INFILE1;
close OUT1;
close OUT2;