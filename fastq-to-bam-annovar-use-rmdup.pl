#!/usr/bin/perl -w
#临时对一个bam的验证.  by JOSH XUAN 2016-11-28 email: 514079685@qq.com
#based on the impact pipline

use strict;
use warnings;

###########################
#This module takes fastq.gz or fq.gz files to annotated annovar vcf files and select the harmful mutants and give the drug information.  
#BWA and hg_exome.fa need to be in your path.
#Samtools version for the snp select. 
#BWA Version 0.7.8-r455 for the mapping. 
#GATK for the PCR dedup ,this pipline without GATK relignment ,because the time maybe too long.
#varscan2 for the indel select.
## I will added the first scoring mechanism for the results.
## I will use the pipline directly give the drugs suggestion for some mutation. 
########################### 

#  PATH declaration
my $path_to_hg_index = "/mnt/home/qsZhang/zqs/software/IMPACT/hg19_index";
my $path_to_PicardTools = "/mnt/data/program/install/picard-tools-1.122";
my $path_to_ref_exome = "/mnt/home/qsZhang/zqs/software/IMPACT/hg19_index";
my $path_to_bcftools = "/mnt/home/qsZhang/zqs/software/samtools-1.2/bcftools-1.2/";
my $path_to_annovar_humandb= "/mnt/data/program/install/annovar.latest/annovar/humandb";

#  variables statement
my $Tumor_R1;
my $Tumor_R1_short;
my $Tumor_R2;
my $Tumor_R2_short;

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
	
open INFILE1, "$Tumor_R1" or die "couldn't open $Tumor_R1\n"; 
open INFILE2, "$Tumor_R2" or die "couldn't open $Tumor_R2\n"; 
close INFILE1;
close INFILE2;


my $Tumor_R1_index = "$Tumor_R1_short".".sai";
my $Tumor_R2_index = "$Tumor_R2_short".".sai";
my $Tumor_sam = "$Tumor_R1_short".".sam";
my $Tumor_bam = "$Tumor_R1_short".".bam";
my $Tumor_sort_bam = "$Tumor_R1_short"."_sort";
my $Tumor_pic_rd1_input = "$Tumor_sort_bam".".bam";
my $Tumor_sort_pic_bam = "$Tumor_sort_bam"."_pic.bam";
my $Tumor_pic_rd2_output = "$Tumor_sort_bam"."dedupped.bam";
my $Tumor_metric = "$Tumor_R1_short".".metric";
my $Tumor_VCF = "$Tumor_R1_short".".vcf";
my $Tumor_cleaned = "$Tumor_R1_short"."cleaned.vcf";
my $Tumor_avi = "$Tumor_R1_short".".avinput";
my $Tumor_annovar = "$Tumor_R1_short".".annovar.vcf";

my $a = system("bwa aln -t 5 $path_to_hg_index/hg19.fa $Tumor_R1 > $Tumor_R1_index ");
my $b = system("bwa aln -t 5 $path_to_hg_index/hg19.fa $Tumor_R2 > $Tumor_R2_index ");
my $c = system("bwa sampe $path_to_hg_index/hg19.fa $Tumor_R1_index $Tumor_R2_index $Tumor_R1 $Tumor_R2 > $Tumor_sam ");
my $d = system("samtools view -Sb $Tumor_sam > $Tumor_bam");
my $e = system("samtools sort $Tumor_bam $Tumor_sort_bam");
my $f = system("java -Xmx4g -Djava.io.tmpdir=./tmp -jar $path_to_PicardTools/SortSam.jar SO=coordinate INPUT=$Tumor_pic_rd1_input OUTPUT= $Tumor_sort_pic_bam VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true");
my $ea = system("samtools rmdup $Tumor_sort_pic_bam $Tumor_pic_rd2_output");
#my $g = system("java -Xmx4g -Djava.io.tmpdir=./tmp -jar $path_to_PicardTools/MarkDuplicates.jar INPUT=$Tumor_sort_pic_bam OUTPUT=$Tumor_pic_rd2_output METRICS_FILE=$Tumor_metric CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT ");
my $h = system("samtools mpileup -C 0 -A -B -d 10000 -v -u -f $path_to_ref_exome/hg19_exome.fa $Tumor_pic_rd2_output | $path_to_bcftools/bcftools call -O v -v -c -n 0.05 -p 1 -A -o $Tumor_VCF ");
my $i = system(" ./change_gt_values.pl $Tumor_VCF  > $Tumor_cleaned ");
my $j = system(" convert2annovar.pl -format vcf4 --includeinfo -coverage 20 -fraction 0.05 $Tumor_cleaned > $Tumor_avi ");
my $k = system(" table_annovar.pl $Tumor_avi $path_to_annovar_humandb -buildver hg19 -out $Tumor_annovar -remove -protocol knowngene,refGene,cosmic70,dbnsfp30a,esp6500si_all,avsnp147,1000g2014oct_all -operation g,g,f,f,f,f,f ");

###fastq to bam 到注释，前半部分。


	