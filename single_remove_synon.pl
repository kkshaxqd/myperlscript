#!/usr/bin/perl -w
use strict;

my $normal = $ARGV[0];  


open INFILE1, "$normal" or die "couldn't open $normal\n";
while (<INFILE1>)
{
       	chomp;
if ($_=~/esp6500si_all/){ print "$_\n"; }
else{	#my @comp_normal = split('\t', $_);
	if ($_ =~ /nonsynonymous/)
		{
		print "$_\n";
		}
	elsif ($_ =~ /frameshift/)
		{
		print "$_\n";
		}
	elsif ($_ =~ /stopgain/)
		{
		print "$_\n";
		}
	elsif ($_ =~ /stoploss/)
		{
		print "$_\n";
		}
	elsif ($_ =~ /UNKNOWN/)
		{
		print "$_\n";
		}
	elsif ($_ =~ /unknown/)
		{
		print "$_\n";
		}
	}
}
close INFILE1;




