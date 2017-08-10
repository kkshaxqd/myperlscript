#!/usr/bin/perl -w
use strict;
use warnings;

my $gzip;


my $x;

if ($ARGV[0]=~/(.*).bam.gz/){$x=$1;}

$gzip = system("gzip -dc $x.bam.gz > $x.bam");

