#!/usr/bin/perl 
use strict;
no warnings;

my @first;
my $mb;

my @common_snps;
my $normal = $ARGV[0];
open INFILE1, "$normal" or die "couldn't open $! found_mutations.txt\n";
while (<INFILE1>)
	{
	my $first_line = $_;
	chomp $first_line;
	if ($first_line=~/esp6500si_all/){ print "$first_line\n"; }
else{
	 my @info = split('\t', $first_line);
		if($info[55] or $info[58])
			{
			if($info[55] < 0.01 or $info[58] < 0.01)          #### EXAC_ALL和EXAC_EAS基因组里大于1%的不要 
				{
				print "$first_line\n";
				}
			else
				{
				#print "$first_line\n";
				}
			}
		else
			{
			print "$first_line\n";
			}
	}		
	}	
close INFILE1;


