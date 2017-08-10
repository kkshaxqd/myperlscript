#!/usr/bin/perl -w

use strict;
my @temp;
my @nextdata;
my @nextnextdata;
my $zuobiao;
my $site;
my %hash;
my $sum=1;
open my $data,"CCDS.current.txt" or die $!;

while(<$data>){
chomp;
next if /^#/;
 @temp=split/\t/,$_;
if ($temp[9]=~/\[(.*)\]/){
 @nextdata=split/,\s/,$1;
foreach $zuobiao (@nextdata){
 @nextnextdata=split/-/,$zuobiao;
foreach  $site ($nextnextdata[0]..$nextnextdata[1])
{$hash{$site}=1}
}
}
}
foreach (keys %hash){$sum++;}
print $sum;
close $data;