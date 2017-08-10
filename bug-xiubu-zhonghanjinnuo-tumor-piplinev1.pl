#!/usr/bin/perl -w
#build the pipline for getting the somatic mutants with tumor and nomorl samples.  by JOSH XUAN 2016-11-28 email: 514079685@qq.com
#based on the impact pipline

use strict;
use warnings;

###########################
#This module takes fastq.gz or fq.gz files to annotated annovar vcf files and select the harmful mutants and give the drug information.  
#BWA and hg_exome.fa need to be in your path.
#Samtools version for the snp select. 
#BWA Version 0.7.8-r455 for the mapping. 
#Picard for the PCR dedup ,this pipline without GATK relignment ,because the time maybe too long.
#varscan2 for the indel select.
## I will added the first scoring mechanism for the results.
## I will use the pipline directly give the drugs suggestion for some mutation. 
########################### 

#  PATH declaration
my $path_to_hg_index = "/mnt/home/qsZhang/zqs/software/IMPACT/hg19_index";
my $path_to_PicardTools = "/mnt/data/program/install/picard-tools-1.122";
my $path_to_ref_exome = "/mnt/home/qsZhang/zqs/software/IMPACT/hg19_index";
my $path_to_bcftools = "/mnt/home/qsZhang/zqs/software/samtools-1.2/bcftools-1.2";
my $path_to_annovar_humandb= "/mnt/data/program/install/annovar.latest/annovar/humandb";
my $path_to_VarScan= "/mnt/local-disk1/home1/qsZhang/zqs/software";
my $path_to_perl= "/mnt/data/program/install/perl-5.18/bin";
#  variables statement
my $Tumor_R1;
my $Tumor_R1_short;
my $Tumor_R2;
my $Tumor_R2_short;
my $Normal_R1;
my $Normal_R1_short;
my $Normal_R2;
my $Normal_R2_short;
#  files reading and filename getting
if ($ARGV[0])
	{
	$Tumor_R1 = $ARGV[0];
	if ($Tumor_R1 =~ /(.*)\.fastq\.gz/ or $Tumor_R1 =~ /(.*)\.fq\.gz/)
		{
		$Tumor_R1_short = $1; 
		} 
	else
		{
		print "\n\n*************************\nERROR: FILE MUST BE .fastq\/fq.gz \nMust provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
		die;
		}
	}
else
	{
	print "\n\n*************************\nERROR: Must provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
	die;
	}
if ($ARGV[1])
	{
	$Tumor_R2 = $ARGV[1];
	if ($Tumor_R2 =~ /(.*)\.fastq\.gz/ or $Tumor_R2 =~ /(.*)\.fq\.gz/)
		{
		$Tumor_R2_short = $1; 
		} 
	else
		{
		print "\n\n*************************\nERROR: FILE MUST BE .fastq\/fq.gz \nMust provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
		die;
		}
	}
else
	{
	print "\n\n*************************\nERROR: Must provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
	die;
	}
if ($ARGV[2])
	{
	$Normal_R1 = $ARGV[2];
	if ($Normal_R1 =~ /(.*)\.fastq\.gz/ or $Normal_R1 =~ /(.*)\.fq\.gz/)
		{
		$Normal_R1_short = $1; 
		} 
	else
		{
		print "\n\n*************************\nERROR: FILE MUST BE .fastq\/fq.gz \nMust provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
		die;
		}
	}
if ($ARGV[3])
	{
	$Normal_R2 = $ARGV[3];
	if ($Normal_R2 =~ /(.*)\.fastq\.gz/ or $Normal_R2 =~ /(.*)\.fq\.gz/)
		{
		$Normal_R2_short = $1; 
		} 
	else
		{
		print "\n\n*************************\nERROR: FILE MUST BE .fastq\/fq.gz \nMust provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
		die;
		}
	}

#########
#check to make sure f.*q.gz can be opened and statement the normal index.
#########
open INFILE1, "$Tumor_R1" or die "couldn't open $Tumor_R1\n"; 
open INFILE2, "$Tumor_R2" or die "couldn't open $Tumor_R2\n"; 
close INFILE1;
close INFILE2;
my $Normal_R1_index;
my $Normal_R2_index;

if ($Normal_R1)
	{
	open INFILE3, "$Normal_R1" or die "couldn't open $Normal_R1\n"; 
	close INFILE3;
	open INFILE4, "$Normal_R2" or die "couldn't open $Normal_R2\n"; 
	close INFILE4;
	$Normal_R1_index = "$Normal_R1_short".".sai";
	$Normal_R2_index = "$Normal_R2_short".".sai";
	}

###########
#Variable Definition
###########
my $Tumor_R1_index = "$Tumor_R1_short".".sai";
my $Tumor_R2_index = "$Tumor_R2_short".".sai";
my $Tumor_sam = "$Tumor_R1_short".".sam";
my $Tumor_bam = "$Tumor_R1_short".".bam";
my $Tumor_sort_bam = "$Tumor_R1_short"."_sort";
my $Tumor_pic_rd1_input = "$Tumor_sort_bam".".bam";
my $Tumor_sort_pic_bam = "$Tumor_sort_bam"."_pic.bam";
my $Tumor_pic_rd2_output = "$Tumor_sort_bam".".dedupped.bam";
my $Tumor_metric = "$Tumor_R1_short".".metric";
my $Tumor_VCF = "$Tumor_R1_short".".vcf";
my $Tumor_VCF2 = "$Tumor_R1_short".".indel.vcf";
my $Tumor_cleaned = "$Tumor_R1_short".".cleaned.vcf";
my $Tumor_avi = "$Tumor_R1_short".".avinput";
my $Tumor_annovar = "$Tumor_R1_short".".annovar.vcf";

my $Normal_sam;
my $Normal_bam;
my $Normal_sort_bam;
my $Normal_sort_pic_bam;
my $Normal_pic_rd1_input;
my $Normal_pic_rd2_output;
my $Normal_metric;
my $Normal_VCF;
my $Normal_VCF2;
my $Normal_cleaned;
my $Normal_avi;
my $Normal_annovar;	

my $i1 = system(" $path_to_perl/perl change_gt_values.pl $Tumor_VCF  > $Tumor_cleaned ");
my $iv = system(" $path_to_perl/perl tumor-DNA-varscan2-filter.pl $Tumor_VCF2  >> $Tumor_cleaned ");
my $j1 = system(" convert2annovar.pl -format vcf4 --includeinfo $Tumor_cleaned | uniq > $Tumor_avi ");
my $k1 = system("  table_annovar.pl $Tumor_avi $path_to_annovar_humandb -buildver hg19 -out $Tumor_annovar -remove -protocol knowngene,refGene,cosmic70,dbnsfp30a,1000g2015aug_eas,1000g2015aug_all,exac03,mcap,clinvar_20150629,avsnp147 -operation g,g,f,f,f,f,f,f,f,f   ");

if ($Normal_R1)
	{
		$Normal_VCF = "$Normal_R1_short".".vcf";
		$Normal_VCF2 = "$Normal_R1_short".".indel.vcf";
	$Normal_cleaned = "$Normal_R1_short"."cleaned.vcf";
	my $t = system(" $path_to_perl/perl change_gt_values.pl $Normal_VCF  > $Normal_cleaned ");
	my $tv = system(" $path_to_perl/perl tumor-DNA-varscan2-filter.pl $Normal_VCF2  >> $Normal_cleaned ");
	$Normal_avi = "$Normal_R1_short".".avinput";
	my $u = system(" convert2annovar.pl -format vcf4 --includeinfo  $Normal_cleaned | uniq > $Normal_avi ");   
	$Normal_annovar = "$Normal_R1_short".".annovar.vcf";
	my $v = system("  table_annovar.pl $Normal_avi $path_to_annovar_humandb -buildver hg19 -out $Normal_annovar -remove -protocol knowngene,refGene,cosmic70,dbnsfp30a,1000g2015aug_eas,1000g2015aug_all,exac03,mcap,clinvar_20150629,avsnp147 -operation g,g,f,f,f,f,f,f,f,f ");
    }
my $Tumor_ann_output = "$Tumor_annovar".".hg19_multianno.txt";
my $Normal_ann_output;
my $Normal_ann2_output;
my $Tumor_ann2_output = "$Tumor_annovar".".hg19_multianno.ann.txt";

my $zz = system("$path_to_perl/perl collect_dinuc.pl $Tumor_ann_output > $Tumor_ann2_output");

if ($Normal_R1) 
	{
	$Normal_ann_output = "$Normal_annovar".".hg19_multianno.txt";
	$Normal_ann2_output = "$Normal_annovar".".hg19_multianno.ann.txt";
	my $zza = system("$path_to_perl/perl collect_dinuc.pl $Normal_ann_output > $Normal_ann2_output");
	my $w = system("$path_to_perl/perl Array_compare.cancer.pl $Normal_ann2_output $Tumor_ann2_output");
	}
###########
#Variable Definition for Second Processing
###########
my $Tumor_no_normal = "$Tumor_R1_short".".annovar.vcf.hg19_multianno.ann.txt";
my $Tumor_no_normal_nonsyn = "$Tumor_R1_short".".nonsyn.txt";
my $Tumor_no_normal_rm1 = "$Tumor_R1_short".".rm1.txt";
my $Tumor_no_normal_rm2 = "$Tumor_R1_short".".final_filtered_VCF.txt";

my $Tumor_minus_normal;
my $Tumor_minus_normal_nonsyn;
my $Tumor_minus_normal_rm1;
my $Tumor_minus_normal_rm2;

if ($Normal_R1)
        {
	$Tumor_minus_normal = "$Tumor_R1_short".".annovar.vcf.hg19_multianno.ann.only_cancer.txt";
	$Tumor_minus_normal_nonsyn = "$Tumor_R1_short".".nonsyn.txt";
	$Tumor_minus_normal_rm1 = "$Tumor_R1_short".".rm1.txt";
	$Tumor_minus_normal_rm2 = "$Tumor_R1_short".".final_filtered_VCF.txt";
	}

###########
#Second Round of Processing 
###########
if ($Normal_R1)
        { 
	my $x = system(" $path_to_perl/perl single_remove_synon.pl $Tumor_minus_normal > $Tumor_minus_normal_nonsyn ");
	my $y = system(" $path_to_perl/perl remove_over.01.one.pl $Tumor_minus_normal_nonsyn > $Tumor_minus_normal_rm1 ");
	my $z = system(" $path_to_perl/perl remove_over.01.three.pl $Tumor_minus_normal_rm1 > $Tumor_minus_normal_rm2 ");    ###使用10000人与EXAC的人群频率来过滤，ESP没有亚洲人的所以不怎么使用。
	}
else
	{
	my $aa = system(" $path_to_perl/perl single_remove_synon.pl $Tumor_no_normal > $Tumor_no_normal_nonsyn ");	
	my $ab = system(" $path_to_perl/perl remove_over.01.one.pl $Tumor_no_normal_nonsyn > $Tumor_no_normal_rm1 ");
	my $ac = system(" $path_to_perl/perl remove_over.01.three.pl $Tumor_no_normal_rm1 > $Tumor_no_normal_rm2 ");
	}	
#########
#Get deleterious mutations from 6 predictors
#########
my $final_output = "$Tumor_R1_short".".final_delet_muts.txt";
my $norm_output_final;
if ($Normal_R1)
        {
	$norm_output_final = "$Tumor_R1_short".".final_delet_muts.txt";
	my $dd = system("$path_to_perl/perl get_deleterious.pl $Tumor_minus_normal_rm2 > $norm_output_final");
        }
else
    	{
	my $dde = system("$path_to_perl/perl get_deleterious.pl $Tumor_no_normal_rm2 > $final_output");
        }
		
###########mcap这个结果其实并不怎样，如果结果少，基本一目了然，或者这个可以和6个预测软件一起起作用。直接在get_deleterious中加上mcap的预测。mcap可能在遗传病中预测会比较好，这个肿瘤里只是做参考吧。以后mcap那步不用了。
######下面主要想增加的两个功能一个是打分机制，另一个就是用药建议#######
###########另外，用药建议是去除CNV部分的，只用snp来做。把CNV部分也整合进来？？暂时impact的CNV部分结果其实并不好。有一些错误，所以暂时不加，以后可以集合进去。

##########
#scoring  mechanism   
##########
my $scoring_output = "$Tumor_R1_short".".final_delet_muts_dafenhou.txt";
#my $scoring_output_final;
if ($Normal_R1)
        {
	$scoring_output = "$Tumor_R1_short".".final_delet_muts_dafenhou.txt";
	my $dd = system("$path_to_perl/perl tumor-first-dafenjizhi.pl $norm_output_final > $scoring_output");
        }
else
    	{
	my $dde = system("$path_to_perl/perl tumor-first-dafenjizhi.pl $final_output > $scoring_output");
        }
#########
#drug information
#########
#my $scoring_output = "$Tumor_R1_short".".final_delet_muts_dafenhou.txt";
my $drug_begin = "$Tumor_R1_short".".combo.txt";
my $dcc = system("cp $scoring_output $drug_begin");  
	
my $mod_3_input = "$Tumor_R1_short".".input";                                                                          ###这两步暂时未见使用。
my $mod_3_output = "$Tumor_R1_short".".allele_frequency.txt";

my @sites;
open INFILE16, "dsig_hyper.txt" or die "couldn't open dsig_hyper.txtn";
while (<INFILE16>)
        {
	chomp;
	push (@sites, $_);
        }
close INFILE16;

########################################################################################################################
#drug module-1
#Link to Actionable Therapeutics
#############

my $title = "$Tumor_R1_short"."_MODULE_drug_OUTPUT.txt";	
open OUTFILE3, ">", "$title" or die "couldn't open $title\n";
my $title2 = "$Tumor_R1_short"."_MODULE_drug_OUTPUT.html";	
open HTMLOUT, ">", "$title2" or die "couldn't open $title\n";

##########################
#Level 1 Output NCI MATCH
#########################
#Dabrafenib and Trametinib	BRAF	V600E	V600K   主要针对的是这些突变，后面可以增加。
#Trametinib	BRAF
#AZD9291	EGFR 	T790M
#Afatinib	EGFR
#Afatinib	HER2
#Sunitinib	KIT
#########################SNPS

my $braf_counter = 0;
print OUTFILE3 "\n
------------------------------------------------------------------------------\n
LEVEL 1: Actionable Therapeutics \n
------------------------------------------------------------------------------\n\n";
print OUTFILE3 "\nNCI Match Clinical Trials\n";
print OUTFILE3 "Mutation					Actionable Therapeutic(s)\n";
print OUTFILE3 "--------					-------------------------\n";

print HTMLOUT "<html><head>
<title>IMPACT OUTPUT for $Tumor_R1_short</title></head>
<body>\n<center><h1>
IMPACT Drug Prediction Analysis <p>
</center></h1>
<br><p><hr><br><p><p><h2>LEVEL 1: Actionable Therapeutics</p></h2>\n<p>NCI Match Clinical Trials</p>\n<table border=\"1\" style=\"width:100%\">\n";
print HTMLOUT "<tr><td><b><center>GENE</td><td><b><center>VARIANT</td><td><b><center>ACTIONABLE THERAPEUTIC(S)</td></tr>\n"; 

my $BRAF = "\"\\bBRAF\\b\"";
my $EGFR = "\"\\bEGFR\\b\"";
my $HER2 = "\"\\bHER2\\b\"";
my $KIT = "\"\\bKIT\\b\"";
my $NF2 = "\"\\bNF2\\b\"";

my $braf_v600e = `grep $BRAF $drug_begin | grep V600E`;
if ($braf_v600e)
	{
	print OUTFILE3 "\tBRAF	V600E					Dabrafenib and Trametinib\n";
	$braf_counter++;
	print HTMLOUT "<tr><td>BRAF</td><td>V600E</td><td><a href= \"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1193\"> Dabrafenib</a> and <a href =\"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1129\"> Trametinib </a></td></tr>\n"; 



	}
my $braf_v600k = `grep $BRAF $drug_begin | grep V600K`;
if ($braf_v600k)
	{
	print OUTFILE3 "\tBRAF	V600K					Dabrafenib and Trametinib\n";
	print HTMLOUT "<tr><td>BRAF</td><td>V600K</td><td><a href= \"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1193\"> Dabrafenib</a> and <a href =\"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1129\"> Trametinib </a></td></tr>\n"; 

	$braf_counter++;
	}
if($braf_counter==0)	
	{
	my $braf_del = `grep $BRAF $drug_begin`;
	if ($braf_del)
        	{
		print OUTFILE3 "\tBRAF	Deleterious				Trametinib\n";
		print HTMLOUT "<tr><td>BRAF</td><td>deleterious</td><td><a href=\"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1129\">Trametinib</a></td></tr>\n"; 
		}
	}
my $egfr_counter = 0;
my $egfr_t790m = `grep $EGFR $drug_begin | grep T790M`;
if ($egfr_t790m)
        {
	print OUTFILE3 "\tEGFR    T790M					AZD9291\n";
	print HTMLOUT "<tr><td>EGFR</td><td>T790M</td><td>AZD9291</td></tr>\n"; 
        $egfr_counter++;
	}

open EG, ">", "EGFR.new.txt" or die "couldn't open EGFR\n";
my $egfr_del = `grep $EGFR $drug_begin`;
print EG "$egfr_del\n";
close EG; 

open INFILE17, "EGFR.new.txt" or die "couldn't open EG.txt\n";
while (<INFILE17>)
        {
	chomp;
	#print $_; 	
        if ($_ =~ /:p.(\w+\d+\w+)\s+/)
                	{
			my $mut = $1;
                	print OUTFILE3 "\tEGFR    $mut	Deleterious				Afatinib\n";
			print HTMLOUT "<tr><td>EGFR</td><td>$mut</td><td><a href= \"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1112\">Afatinib</a></td></tr>\n"; 
                	}
		}
close INFILE17; 

my $her2 = `grep $HER2 $drug_begin| grep SNV `;
if ($her2 =~ /:p.(\D+\d+\D+)\s+/)
        {
	my $mut = $1;
	print OUTFILE3 "\tHER2	$mut	Deleterious			Afatinib\n";
	print HTMLOUT "<tr><td>HER2</td><td>$mut</td><td><a href= \"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1112\">Afatinib</a></td></tr>\n"; 
	}
my $kit = `grep $KIT $drug_begin `;
if ($kit =~ /:p.(\D+\d+\D+)\s+/)
        {
	my $mut = $1;
	print OUTFILE3 "\tKIT	$mut	Deleterious			Sunitinib\n";
	print HTMLOUT "<tr><td>KIT</td><td>$mut</td><td><a href= \"http://tanlab.ucdenver.edu/DSigDB/DSigDBv1.0/displayDrug.py?db=d1&id=1006\">Sunitinib</a></td></tr>\n"; 
	}
#####################################################################################
# added MDA kiro的匹配，所有新生成的文件名字后面全加上.new标志
#####################################################################################
print OUTFILE3 "\nMD Anderson Personalized Cancer Therapy\n";
print OUTFILE3 "Mutation					Actionable Therapeutic(s)\n";
print OUTFILE3 "--------					-------------------------\n";
	
print HTMLOUT "<p>MD Anderson Personalized Cancer Therapy</p>\n<table border=\"1\" style=\"width:100%\">\n";
#print HTMLOUT "<tr><td><b><center>GENE</td><td><b><center>VARIANT</td><td><b><center>ACTIONABLE THERAPEUTIC(S)</td></tr>\n"; 


my %mda; 
open INFILE1MDA4, "MDA.txt" or die "couldn't open MDA.txt\n";
while (<INFILE1MDA4>)
        {
	chomp;
	my @info = split(',', $_);	
	my $gene = shift @info;
	my $string; 
	foreach(@info)
		{
		if ($string)
			{
			$string = "$string".",$_";
			}
		else
			{
			$string = $_;
			}
		}
	$mda{$gene} = $string;	
	}
close INFILE1MDA4 ;
while ( my ($key, $value) = each(%mda) ) 
	{
	my $grep = "\"\\b$key\\b\"";
	my $get_grep = `grep $grep $drug_begin `;

	open KEY, ">", "$key.new.txt" or die "couldn't open $key.txt\n";
	print KEY "$get_grep\n";
	close KEY;

	open INFILE18, "$key.new.txt" or die "couldn't open $key.txt\n";
	while (<INFILE18>)
        	{
		chomp;
		#print $_;
        	if ($_ =~ /:p.(\w+\d+\w+)\s+/)
                        {
			my $mut = $1;
        		print OUTFILE3 "\t$key\t$mut\t\t\t$value\n";
			print HTMLOUT "<tr><td>$key</td><td>$mut</td><td>\n"; 
			my @info = split(',', $value);
			foreach(@info)
				{
				my $cur_drug = $_;
				my $match = 0;
				foreach(@sites)
					{
					my @info2 = split('\t', $_);
					chomp $info[0];
					if ("$cur_drug" eq "$info2[0]")
						{
						print HTMLOUT "<a href=\"$info2[1]\">$cur_drug </a>";
						$match =1;
						}
					}
				if($match == 0)
					{
					print HTMLOUT "$cur_drug ";
					}
				}
        		print HTMLOUT "</td></tr>\n";
                        }
                }
	close INFILE18;
	}
print OUTFILE3 "\nDsigDB  FDA approved Kinase Inhibitors\n";
print OUTFILE3 "Mutation					Actionable Therapeutic(s)\n";
print OUTFILE3 "--------					-------------------------\n";
        print HTMLOUT "</table>\n";

print HTMLOUT "<p>DSigDB FDA Approved Kinase Inhibitors</p>\n<table border=\"1\" style=\"width:100%\">\n";
print HTMLOUT "<tr><td><b><center>GENE</td><td><b><center>VARIANT</td><td><b><center>ACTIONABLE THERAPEUTIC(S)</td></tr>\n"; 

my %keio; 
open INFILE1KEIO4, "kieo.txt" or die "couldn't open keio.txt\n";
while (<INFILE1KEIO4>)
        {
	chomp;
	my @info = split(',', $_);	
	my $gene = shift @info;
	my $string; 
	foreach(@info)
		{
		if ($string)
			{
			$string = "$string".",$_";
			}
		else
			{
			$string = $_;
			}
		}
	$keio{$gene} = $string;	
	}
close INFILE1KEIO4;

while ( my ($key, $value) = each(%keio) )
        {
	my $key_held = 0; 
	if ($key =~ /(.*)\/(.*)/)
		{
		$key_held =  "$1_$2\n";
		#print "$key\n";
		}
	my $grep = "\"\\b$key\\b\"";
        my $get_grep = `grep $grep $drug_begin `;

        open KEY, ">", "$key_held.new.txt" or die "couldn't open $key_held.txt\n";
        print KEY "$get_grep\n";
        close KEY;

        open INFILE18, "$key_held.new.txt" or die "couldn't open $key_held.txt\n";
        while (<INFILE18>)
                {
                chomp;
                #print $_;
                if ($_ =~ /:p.(\w+\d+\w+)\s+/)
                        {
			my $mut = $1;
        		print OUTFILE3 "\t$key\t$mut\t\t\t$value\n";
			print HTMLOUT "<tr><td>$key</td><td>$mut</td><td>\n"; 
			my @info = split(',', $value);
			foreach(@info)
				{
				my $cur_drug = $_;
				my $match = 0;
				foreach(@sites)
					{
					my @info2 = split('\t', $_);
					if ("$cur_drug" eq "$info2[0]")
						{
						print HTMLOUT "<a href=\"$info2[1]\">$cur_drug </a>";
						$match =1;
						}
					}
				if($match == 0)
					{
					print HTMLOUT "$cur_drug ";
					}
				}
        		print HTMLOUT "</tzd></tr>\n";
                        }
                }
        close INFILE18;
        }

        print HTMLOUT "</table>\n";
		
####################
#Level 2 Output
####################

print OUTFILE3 "\n
------------------------------------------------------------------------------\n
LEVEL 2 Actionable Therapeutics from DsigDB Database \n
------------------------------------------------------------------------------\n\n";

print HTMLOUT "<p></p><p><h2>LEVEL 2: Actionable Therapeutics from DSigDB</p></h2>\n<table border=\"1\" style=\"width:100%\">\n";


my @genes; 

#cut -f 7 TCGA_C_4494.final_delet_muts.txt | sort | uniq |
my $mod_4_input = "$Tumor_R1_short".".delt_genes.txt";
my $ee = system("cut -f 7 $drug_begin | sort | uniq > $mod_4_input");
open INFILE11, "$mod_4_input" or die "couldn't open $mod_4_input\n";
while(<INFILE11>)
        {
        chomp;
	push @genes, "$_";
        }
close INFILE11;

my $len = scalar @genes;   ###得到数组长度
print OUTFILE3 "Potential Gene Targets($len):\n@genes\n\n";
print HTMLOUT "<p>Potential Gene Targets($len):\n@genes</p>";


my @D1_genes; 

open INFILE8, "D1_geneList.txt" or die "couldn't open D1_geneList.txt\n";
while(<INFILE8>)
        {
	chomp;
	my $d1 = $_; 
	foreach (@genes)
		{
		if ("$_" eq "$d1")
			{
			#print "$_ is on D1 $d1\n";  
			push @D1_genes, "$_"; 
			}
		}
	}
close INFILE8; 

@genes = @D1_genes; 

my %drugs;
my @drug_array;
open INFILE10, "DSigDB_D1_data_set.txt" or die "couldn't open DSigDB_D1_data_set.txt\n";
while(<INFILE10>)
	{
	chomp;
	my @targets = split('\t', $_);	
	my $name_drug = shift @targets;
	my $site = shift @targets;
	foreach(@genes) 
		{
		my $gene = $_;
		#only push onto the hofAs if in the gene list
		if ( grep { $_ eq $gene} @targets )
			{
			#print "MATCHES $_ \t $gene \n"; 
			$drugs{$name_drug} = [@targets];    ###让地址等于键值
			}
		}
	}
close INFILE10;

my @list_drugs;
my @gene_list; 
my @matches;
foreach my $family ( keys %drugs )
	{
	#print "$family: @{ $drugs{$family} }\n"
	push @list_drugs, $family;
	push @gene_list, @{ $drugs{$family} };
	}
my @unique = uniq( @gene_list );
#print "@list_drugs\n@unique\n";

#print "\t";
foreach(@unique)
	{
	#print "$_\t";
	}
#print "\n";
print HTMLOUT "<tr><td><b><center>DRUG</td><td><b><center>TARGETS HIT</td><td><b><center>POTENTIAL TARGETS</td><td><b><center>P-value (hypergeometric test)</td><td><b><center>P-value (Permutation test)</td></tr>\n"; 
print OUTFILE3 "Drug\t\t\tTargets Hit\t\tPotential Targets\tP-value (hypergeometric test)\tP-value (Permutation test)\n";
open OUTFILE2, ">", "druglist.txt" or die "couldn't open druglist.txt\n";

foreach my $family ( keys %drugs )
	{
	#my $get_line = "$family\t";
	#print "$family\t";
	my $one_counts = 0;
	my $two_counts = 0;
	my $zero_counts = 0; 

	foreach(@unique)
		{
		my $flag1 = 0; 
		my $fg2 = 0; 
		my $match1 = $_;
		#print "$match1\n";
		foreach(@{ $drugs{$family} })
 			{
			my $match2 = $_;
			#print "$match2\n";
			if ("$match1" eq "$match2")
				{
				$flag1 = 1;
				foreach(@genes)
					{
					my $match3 = $_;
		                        if ("$match3" eq "$match2")
                                		{
                     		        	$flag1 = 2;
						}
					}
				#print "2\t";
				}
			}
		if ($flag1 == 1)
			{
			#print "1\t";	
			$one_counts++;
			}
	        if ($flag1 == 2)
        	        {
                	#print "2\t";
			$two_counts++;
                	}
	        if ($flag1 == 0)
        	        {
                	#print "0\t";
			$zero_counts++;
                	}
		}
	#print "\t";
	#print "$one_counts\t$two_counts\t$zero_counts\n";
	#phyperscript
	#xag, q vector of quantiles representing the number of white balls drawn  without replacement from an urn which contains both black and white balls.
	#mag the number of white balls in the urn.
	#nag the number of black balls in the urn.
	#kag the number of balls drawn from the urn.
	my $gene_target_for_drug = $two_counts + $one_counts;
	my $xag = $two_counts;
	my $mag = $gene_target_for_drug;
	my $nag = (1288-$gene_target_for_drug);
	my $kag = @genes;
	#print "\t$x\t$m\t$n\t$k\t";
	#$get_line = "$family\t"."\t$x\t$m\t$n\t$k\t";
	push @matches,"$xag\t$kag\t$mag";

		print OUTFILE2 "$family\t\t$xag\t$mag\t\n";

	}

open OUTFILE1, ">", "hyperTest.txt" or die "couldn't open hyperTest.txt\n";
	foreach(@matches)
		{
		print OUTFILE1 "$_\n";
		}
close OUTFILE1;
close OUTFILE2;
#close OUTFILE3;

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}

####################################
#计算P值
####################################
my $just_second_step = `./PermRHypertest.sh ` ;   ###原来这个`PermRHypertest hyperTest.txt > p_values.txt` 不识别，直接在.sh脚本中加入这句就可以了。
#my $just_second_step1 = `PermRHypertest hyperTest.txt > p_values.txt` ;

####################################
#drug information last step
####################################

my @gene; 
open INFILE14, "druglist.txt" or die "couldn't open druglist.txt\n";
while (<INFILE14>)
        {
	chomp;
	push (@gene, $_);
	}

my @nci; 
open INFILE44, "druglist2.txt" or die "couldn't open druglist.txt\n";
while (<INFILE44>)
        {
	chomp;
	push (@nci, $_);
	}

foreach(@gene)
	{
#	print "$_\n";
	}	
my @p; 
my @p2;
open INFILE15, "p_values.txt" or die "couldn't open p_values.txt\n";
while (<INFILE15>)
        {
	chomp;
	my @info = split("\t", $_);
	push (@p, $info[-1]);	
	push (@p2, $info[-2]);	
	}
close INFILE14; 
close INFILE15; 
close INFILE44; 

my @sites1; 
open INFILE16, "dsig_hyper.txt" or die "couldn't open dsig_hyper.txtn";
while (<INFILE16>)
        {
	chomp;
	push (@sites1, $_);	
	}
close INFILE16; 


my $amount = @gene; 
my $amount2 = @p; 
#print "$amount\t$amount2\n";
my $count = 0; 
my $top = shift @p;
my $top2 = shift @p2;
my %output; 

while ($count < $amount)
	{
	my $one1 = shift @gene;
	my $three1 = shift @p2;
	my $three21 = sprintf "%.3f", $three1;
	my $combo = "$one1"."\t$three21";
	my $two1 = shift @p;
	$output{$combo} = $two1;
	$count++
	}

while ( my ($key, $value) = each(%output) ) {
        #print "$key \t\tHEY\t\t $value\n";
    }

my $output_count = 0;
foreach my $name (sort { $output{$a} <=> $output{$b}or $b cmp $a } keys %output) 
	{
	foreach(@nci)
		{
		my $nci_drug = $_; 
		if ($name =~ /$nci_drug/)
			{
			printf OUTFILE3 "%-8s %s\n", $name, $output{$name};
			if($name =~/(\D+)\s+(\S+)\s+(\S+)\s+(\S+)/)
				{
				my $website; 
				foreach(@sites1)
					{
					my @info2 = split("\t", $_);
					my $drug_web = $info2[0]; 
					#print "drug_web
					if ("$drug_web" eq "$nci_drug")
						{
						$website = $info2[1];
					 	}
					}
				print "$1\t$2\t$3\t$4\t$output{$name}\n";
				print HTMLOUT "<tr><td><a href=\"$website\">$1</a></td><td>$2</td><td>$3</td><td>$4</td><td>$output{$name}</td></tr>\n";
				}
			}
		}
	$output_count++;
	}
print HTMLOUT "</table>\n";
close OUTFILE3; 
close HTMLOUT; 
########################somatic variants heterogeneity##############
#This Program extract allele frequency from VCF file for somatic variants present in tumor sample
#As input it needs two files first VCF file of tumor sample and second information of tumor somatic 
#variants coordinates (tab separated chr Start_position End_position)
#As Output it will provide information variant information from VCF and last column with Allele frequency
####################################################################

my $mod_svh_input = "$Tumor_R1_short".".input";
my $mod_svh_output = "$Tumor_R1_short".".allele_frequency.txt";
my %store;
my $chr;
my $pos;
my $id;
my @temp;
my $read;
my $ref_read;
my $alt_read;
my $AF;
if ($Normal_R1)
{
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
}
close FILE;
close SFILE;		
close WFILE;
				