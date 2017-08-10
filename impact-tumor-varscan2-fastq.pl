#!/usr/bin/perl -w
use strict; 
####修改者，张桥石，514079685@qq.com 2016-11-16#####
###########################
#对肿瘤样本的fastq或者fq进行处理，然后采用impact修正后的方法完成这个任务，得到想要的体细胞突变。之前samtools call变异结果对indel不是太好，现在改用varscan2来call。
#BWA and hg_exome.fa need to be in your path
#Samtools version 1.2   /    VarScan.v2.3.9
#BWA Version 0.7.8-r455
#GenomeAnalysisTK 3.30
###########################

####路径声明
my $path_to_hg_index = "/mnt/home/qsZhang/zqs/software/IMPACT/hg19_index";
my $path_to_PicardTools = "/mnt/data/program/install/picard-tools-1.122";
my $path_to_ref_exome = "/mnt/home/qsZhang/zqs/software/IMPACT/hg19_index";
my $path_to_bcftools = "/mnt/home/qsZhang/zqs/software/samtools-1.2/bcftools-1.2/";
my $path_to_annovar_humandb= "/mnt/data/program/install/annovar.latest/annovar/humandb";
my $path_to_GenomeAnalysisTK= "/mnt/home/qsZhang/zqs/software/GenomeAnalysisTK-3.3-0";
my $path_to_VarScan= "/mnt/local-disk1/home1/qsZhang/zqs/software";

my $Tumor_R1;
my $Tumor_R1_short;
my $Tumor_R2;
my $Tumor_R2_short;

####读取文件
if ($ARGV[0])
	{
	$Tumor_R1 = $ARGV[0];
	if ($Tumor_R1 =~ /(.*)\.fastq\.gz/  or $Tumor_R1 =~ /(.*)\.fq\.gz/)
		{
		$Tumor_R1_short = $1; 
		} 
	else
		{
		print "\n\n*************************\nERROR: FILE MUST BE .fastq.gz \nMust provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
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
		print "\n\n*************************\nERROR: FILE MUST BE .fastq.gz \nMust provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
		die;
		}

	}
else
	{
	print "\n\n*************************\nERROR: Must provide paired-end whole exome sequencing data.\n To use: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz\n Can also be used with matched normal samples: ./Module_1_fastq_vcf.pl Tumor1_R1.fastq.gz Tumor1_R2.fastq.gz Normal1_R1.fastq.gz Norma11_R2.fastq.gz\n\n*************************\n\n";
	die;
	}

####看能否打开文件
open INFILE1, "$Tumor_R1" or die "couldn't open $Tumor_R1\n"; 
open INFILE2, "$Tumor_R2" or die "couldn't open $Tumor_R2\n"; 
close INFILE1;
close INFILE2;
#####记录程序执行信心
##my $kaishi=system("script $Tumor_R1_short.log.txt");   ##并不可以。

####变量声明
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
my $Tumor_cleaned = "$Tumor_R1_short".".cleaned.vcf";
my $Tumor_avi = "$Tumor_R1_short".".avinput";
my $Tumor_annovar = "$Tumor_R1_short".".annovar.vcf";

######从fastq开始的正式步骤，还是使用aln算法得到的reads数比mem算法的多一些，最后的结果可能好些
my $a = system("bwa aln -t 5 $path_to_hg_index/hg19.fa $Tumor_R1 > $Tumor_R1_index ");
my $b = system("bwa aln -t 5 $path_to_hg_index/hg19.fa $Tumor_R2 > $Tumor_R2_index ");
my $c = system("bwa sampe $path_to_hg_index/hg19.fa $Tumor_R1_index $Tumor_R2_index $Tumor_R1 $Tumor_R2 > $Tumor_sam ");
my $d = system("samtools view -Sb $Tumor_sam > $Tumor_bam");
my $e = system("samtools sort $Tumor_bam $Tumor_sort_bam");
my $f = system("java -Xmx4g -Djava.io.tmpdir=./tmp -jar $path_to_PicardTools/SortSam.jar SO=coordinate INPUT=$Tumor_pic_rd1_input OUTPUT= $Tumor_sort_pic_bam VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true");
my $g = system("java -Xmx4g -Djava.io.tmpdir=./tmp -jar $path_to_PicardTools/MarkDuplicates.jar INPUT=$Tumor_sort_pic_bam OUTPUT=$Tumor_pic_rd2_output METRICS_FILE=$Tumor_metric CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT ");

####正式步骤+另外，我想增加indel重排，使用GATK的方法对bam进行重修正，dedup.bam都是只经过sort和去PCR偏好的bam文件。
####有bai索引文件，所以不用重建，另外，bwa mem 的已经加了名称，不用重加。GATK使用之前要注意。
####bam修正分为indel重排，BQSR校正

###然而并没有什么效果？时间不太够。以后评测，先做其他样本的吧。
#my $f = system("java -Xmx8g -Djava.io.tmpdir=./tmp1 -jar $path_to_GenomeAnalysisTK/GenomeAnalysisTK.jar  -T RealignerTargetCreator  -R $path_to_ref_exome/hg19.fa  -o $inputbamlist  -I $Tumor_pic_rd2_output -known $path_to_ref_exome/1000G_phase1.indels.hg19.vcf -known $path_to_ref_exome/Mills_and_1000G_gold_standard.indels.hg19.vcf ");
#my $g = system("java -Xmx8g -Djava.io.tmpdir=./tmp1 -jar $path_to_GenomeAnalysisTK/GenomeAnalysisTK.jar  -T IndelRealigner -R $path_to_ref_exome/hg19.fa  -targetIntervals $inputbamlist  -I $Tumor_pic_rd2_output -o $Tumor_bam_realigned  -known $path_to_ref_exome/1000G_phase1.indels.hg19.vcf -known $path_to_ref_exome/Mills_and_1000G_gold_standard.indels.hg19.vcf ");

#my $v = system("java -Xmx8g -Djava.io.tmpdir=./tmp1 -jar $path_to_GenomeAnalysisTK/GenomeAnalysisTK.jar  -T BaseRecalibrator -R $path_to_ref_exome/hg19.fa -I $Tumor_bam_realigned -o $samplerecalgrp -knownSites $path_to_ref_exome/dbsnp_138.hg19.vcf  -knownSites $path_to_ref_exome/1000G_phase1.indels.hg19.vcf -knownSites $path_to_ref_exome/Mills_and_1000G_gold_standard.indels.hg19.vcf ");
#my $x = system("java -Xmx8g -Djava.io.tmpdir=./tmp1 -jar $path_to_GenomeAnalysisTK/GenomeAnalysisTK.jar  -T BaseRecalibrator -R $path_to_ref_exome/hg19.fa -I $Tumor_bam_realigned -BQSR $samplerecalgrp -o $samplepostrecalgrp  -knownSites $path_to_ref_exome/dbsnp_138.hg19.vcf -knownSites $path_to_ref_exome/1000G_phase1.indels.hg19.vcf -knownSites $path_to_ref_exome/Mills_and_1000G_gold_standard.indels.hg19.vcf ");
#my $y = system("java -Xmx8g -Djava.io.tmpdir=./tmp1 -jar $path_to_GenomeAnalysisTK/GenomeAnalysisTK.jar  -T PrintReads -R $path_to_ref_exome/hg19.fa -I $Tumor_bam_realigned -BQSR $samplerecalgrp -o $Tumor_bam_realigned_recal");

#原来GATK步骤，这个太耗时间了，并且那些校正看起来并没有什么用。
#my $h1 = system("samtools mpileup -C 100 -E -d 10000 -v -u -f $path_to_ref_exome/hg19_exome.fa $Tumor_bam_realigned_recal | $path_to_bcftools/bcftools call -O v -v -c -A -o $Tumor_VCF");
#非GATK，原本的流程，时间快些。
#samtools mpileup -C 0 -A -B -d 10000 -v -u -f $path_to_ref_exome/hg19_exome.fa $Normal_pic_rd1_input | $path_to_bcftools/bcftools call -O v -v -c -n 0.05 -p 1 -A -o $Normal_VCF
#samtools mpileup -C 0 -A -B -d 10000 -v -u -f $path_to_ref_exome/hg19_exome.fa $Tumor_pic_rd1_input | $path_to_bcftools/bcftools call -O v -v -c -n 0.05 -p 1 -A -o $Tumor_VCF
#my $h = system("samtools mpileup -C 100 -B -A -d 10000 -v -u -f $path_to_ref_exome/hg19_exome.fa $Tumor_pic_rd2_output  -o $Tumor_BCF ");
#my $hjj = system("$path_to_bcftools/bcftools call -O v -v -m -A $Tumor_BCF -o $Tumor_VCF");  -m不行，-c也不行，这两个生成的vcf只有几十兆而且没有大DP的竟然、、。

#my $h = system("samtools mpileup -C 100 -ABuvp -d 10000 -q 60 -Q 30 -f $path_to_ref_exome/hg19_exome.fa $Tumor_pic_rd2_output | $path_to_bcftools/bcftools call -O v -c -A -o $Tumor_VCF ");
###改用VarScan进行变异call取。
my $hv = system("samtools mpileup -B -d 10000  -f $path_to_ref_exome/hg19_exome.fa $Tumor_pic_rd2_output | java -jar $path_to_VarScan/VarScan.v2.3.9.jar mpileup2cns --output-vcf 1 > $Tumor_VCF ");

my $i = system(" ./tumor-DNA-varscan2-filter.pl $Tumor_VCF  > $Tumor_cleaned ");
my $j = system(" convert2annovar.pl -format vcf4 --includeinfo $Tumor_cleaned > $Tumor_avi ");
my $k = system(" table_annovar.pl $Tumor_avi $path_to_annovar_humandb -buildver hg19 -out $Tumor_annovar -remove -protocol knowngene,refGene,cosmic70,dbnsfp30a,esp6500si_all,mcap,1000g2014oct_all,clinvar_20150629,snp138,exac03 -operation g,g,f,f,f,f,f,f,f,f ");


####我也不知道这个有什么用，原来impact自带的，和正常样本共同起作用的可能。这里可能不用。 嗯，的确不用，这是与正常样本比对所用的。
my $Tumor_ann_output = "$Tumor_annovar".".hg19_multianno.txt";
my $Tumor_ann2_output = "$Tumor_annovar".".hg19_multianno.ann.txt";
#my $zz = system("./collect_dinuc.pl $Tumor_ann_output > $Tumor_ann2_output");


###########
#Variable Definition for Second Processing
###########
#my $Tumor_no_normal = "$Tumor_R1_short".".annovar.vcf.hg19_multianno.ann.txt";
my $Tumor_no_normal = "$Tumor_R1_short".".annovar.vcf.hg19_multianno.txt";
my $Tumor_no_normal_nonsyn = "$Tumor_R1_short".".nonsyn.txt";
my $Tumor_no_normal_rm1 = "$Tumor_R1_short".".rm1.txt";
my $Tumor_no_normal_rm2 = "$Tumor_R1_short".".final_filtered_VCF.txt";

 ###########
#Second Round of Processing 
###########
my $aa = system(" ./single_remove_synon.pl $Tumor_no_normal > $Tumor_no_normal_nonsyn ");	  ###得到非同义的移码的停止的未知的突变
my $ab = system(" ./remove_over.01.one.pl $Tumor_no_normal_nonsyn > $Tumor_no_normal_rm1 ");  ###千人基因组中大于1%的不要
my $ac = system(" ./remove_over.01.two.pl $Tumor_no_normal_rm1 > $Tumor_no_normal_rm2 ");     ###ESP6500中大于1%的不要

#########
#Get deleterious mutations from 6 predictors
#########
my $final_output = "$Tumor_R1_short".".final_delet_muts.txt";
my $dde = system("./get_deleterious.pl $Tumor_no_normal_rm2 > $final_output");
#########
#增加mcap筛选
#########
my $final_output_mcap = "$Tumor_R1_short".".final_delet_muts_mcap.txt";
my $cc = system("./mcap-jie-guo-hang-tiqu.pl $final_output $final_output_mcap");
	
#####程序运行结束
######my $jieshu=system("exit");	