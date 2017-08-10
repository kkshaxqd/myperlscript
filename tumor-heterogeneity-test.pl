#!/usr/bin/perl -w
use strict; 
########################somatic variants heterogeneity##############
#This Program extract allele frequency from VCF file for somatic variants present in tumor sample
#As input it needs two files first VCF file of tumor sample and second information of tumor somatic 
#variants coordinates (tab separated chr Start_position End_position)
#As Output it will provide information variant information from VCF and last column with Allele frequency
####################################################################
my $Tumor_minus_normal = "S224_06A_CHG008211-A-2-G4-31_L008_R1".".annovar.vcf.hg19_multianno.ann.only_cancer.txt";
my $mod_svh_input = "S224_06A_CHG008211-A-2-G4-31_L008_R1".".input";
my $mod_svh_output = "S224_06A_CHG008211-A-2-G4-31_L008_R1".".allele_frequency.txt";
my $Tumor_VCF = "S224_06A_CHG008211-A-2-G4-31_L008_R1".".vcf";
my %store;
my $line;
my $chr;
my $pos;
my $id;
my @temp;
my $read;
my $ref_read;
my $alt_read;
my $AF;
#if ($Normal_R1)
#{
my $cutting = system("cut -f 1,2,3 $Tumor_minus_normal > $mod_svh_input");

open(FILE,$Tumor_VCF);
open(SFILE,$mod_svh_input);
open(WFILE,">$mod_svh_output");
while(<SFILE>)
{
   chomp;
if ($_!~/Start/)
	{
	@temp=split("\t",$_);
	$chr=$temp[0];
	if($chr=~m/^chr[0-9]+|^chrX|^chrY/ig)
	{
		$pos=$temp[1];
		$id=$chr."_".$pos;	
		$store{$id}=$_;
	}
	}
}
#Extract information of somatic variants from VCF file; 
#Allele frequency information was calculated based on DP4 flag that gives number reads support alternate and reference allele
# and there distribution on both strand. 
while(<FILE>)
{
    chomp;
  if($_!~/#/) 
	{
	@temp=split("\t",$_);
	$chr=$temp[0];
	$pos=$temp[1];
	$id=$chr."_".$pos;
	if(exists $store{$id})
	{
		$pos=$temp[1];
		$read=$temp[7];
		$read=~m/DP4=([0-9]+),([0-9]+),([0-9]+),([0-9]+)/ig;
		$ref_read=$1+$2;
		$alt_read=$3+$4;
		$AF=$alt_read/($ref_read + $alt_read);
		print WFILE $_."\t".$store{$id}."\t".$AF."\n";
	}
	}
}
#}
close FILE;
close SFILE;		
close WFILE;
######chongzhushi#####
my $mod_svh_avi="S224_06A_CHG008211-A-2-G4-31_L008_R1".".allele_frequency.temp.avinput";
my $mod_svh_annovar="S224_06A_CHG008211-A-2-G4-31_L008_R1".".allele_frequency.annovar.temp.vcf"
my $mod_svh_temp="S224_06A_CHG008211-A-2-G4-31_L008_R1".".af.temp"
my $mod_svh_temp_out="S224_06A_CHG008211-A-2-G4-31_L008_R1".".af.temp.out"
my $mod_svh_xiuzhenghou="S224_06A_CHG008211-A-2-G4-31_L008_R1".".allele_frequency.chongxiuzheng.txt"
my $chongzhushi = system("convert2annovar.pl -format vcf4 --includeinfo $mod_svh_output > $mod_svh_avi");
my $kchongzhushi = system("table_annovar.pl $mod_svh_avi /mnt/data/program/install/annovar.latest/annovar/humandb -buildver hg19 -out $mod_svh_annovar -remove -protocol knowngene,refGene,cosmic70,1000g2014oct_all,exac03,mcap,clinvar_20150629,avsnp147 -operation g,g,f,f,f,f,f,f ");
my $gchongzhushi = system("cut -f 6,8,10,14 $mod_svh_output > $mod_svh_temp");
open(FILE,$mod_svh_temp);
open(WFILE,">$mod_svh_temp_out");
print WFILE "QUAL\tINFO\tSample\tAllele_Frequency\n";
while(<FILE>)
{
    chomp;
	print WFILE "$_\n";
}
my $hchongzhushi = system("paste $mod_svh_annovar $mod_svh_temp_out > $mod_svh_xiuzhenghou");
my $jchongzhushi = system ("rm *.temp.*");
