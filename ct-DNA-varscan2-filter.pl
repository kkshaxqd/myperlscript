#!/usr/bin/perl -w
use strict;
#INFO=<ID=ADP,Number=1,Type=Integer,Description="Average per-sample depth of bases with Phred score >= 15">
##INFO=<ID=WT,Number=1,Type=Integer,Description="Number of samples called reference (wild-type)">
##INFO=<ID=HET,Number=1,Type=Integer,Description="Number of samples called heterozygous-variant">
##INFO=<ID=HOM,Number=1,Type=Integer,Description="Number of samples called homozygous-variant">
##INFO=<ID=NC,Number=1,Type=Integer,Description="Number of samples not called">
##FILTER=<ID=str10,Description="Less than 10% or more than 90% of variant supporting reads on one strand">
##FILTER=<ID=indelError,Description="Likely artifact due to indel reads at this position">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
##FORMAT=<ID=SDP,Number=1,Type=Integer,Description="Raw Read Depth as reported by SAMtools">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Quality Read Depth of bases with Phred score >= 15">
##FORMAT=<ID=RD,Number=1,Type=Integer,Description="Depth of reference-supporting bases (reads1)">
##FORMAT=<ID=AD,Number=1,Type=Integer,Description="Depth of variant-supporting bases (reads2)">
##FORMAT=<ID=FREQ,Number=1,Type=String,Description="Variant allele frequency">
##FORMAT=<ID=PVAL,Number=1,Type=String,Description="P-value from Fisher's Exact Test">
##FORMAT=<ID=RBQ,Number=1,Type=Integer,Description="Average quality of reference-supporting bases (qual1)">
##FORMAT=<ID=ABQ,Number=1,Type=Integer,Description="Average quality of variant-supporting bases (qual2)">
##FORMAT=<ID=RDF,Number=1,Type=Integer,Description="Depth of reference-supporting bases on forward strand (reads1plus)">
##FORMAT=<ID=RDR,Number=1,Type=Integer,Description="Depth of reference-supporting bases on reverse strand (reads1minus)">
##FORMAT=<ID=ADF,Number=1,Type=Integer,Description="Depth of variant-supporting bases on forward strand (reads2plus)">
##FORMAT=<ID=ADR,Number=1,Type=Integer,Description="Depth of variant-supporting bases on reverse strand (reads2minus)">

my $x1 = $ARGV[0];  #put name of file as command line argument

my $MB_number;
my $gene;
my $type_of_mut;
my $flag = 0; 

open INFILE1, "$x1" or die "couldn't open $x1\n";
while (<INFILE1>)
       	{
       	chomp;
	$flag = 0;
	my @info = split('\t', $_);
	if ($_ =~ /^#/)
		{
		print "$_\n";
		next;
		}
	else
		{
		
				if ($info[9]=~ /((\d\/\d):(\d+):(\d+):(\d+):(\d+):(\d+):(\S+)\%:(\S+):(\d+):(\d+):(\d+):(\d+):(\d+):(\d+))/)  ## GT:GQ:SDP:DP:RD:AD:FREQ:PVAL:RBQ:ABQ:RDF:RDR:ADF:ADR
					{
					my $sum_all = $4;
					my $var_sum = $7;
					my $var_frequence= $8;
					my $var_sam_fan= $15;
					my $var_sam_zheng= $14;
					if ($var_sum > 0)
					 {
					#my $per_var = $var_sum/$sum_all;
					if ($var_frequence > 0.001 && $var_frequence < 0.01 && $sum_all >= 200  )  ####if ($per_var > .1 && $sum_all > 20 && $var_sum > 4)
						{
						if($info[9] =~ /0\/0(.*)/)
							{
							$flag = 1;
							print "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\t$info[8]\t0/1$1\n";
							}
						else{
							 print "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\t$info[8]\t$info[9]\n";
							}
						}
					 }
					}
				
			#if ($flag =~ /0/)
				#{
				#print "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\t$info[8]\t$info[9]\n";
				#}
			

		}
	}
close INFILE1;