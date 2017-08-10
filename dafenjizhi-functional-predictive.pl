#!/usr/bin/perl -w
####修改者，张桥石，514079685@qq.com 2016-10-31#####
###########################
####筛选打分机制。

use strict;


$/=undef;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";
my $fin1=<FILE1>;

#my $taitou="Chr	Start	End	Ref	Alt	Func.refGene	Gene.refGene	GeneDetail.refGene	ExonicFunc.refGene	AAChange.refGene	cytoBand	genomicSuperDups	OMIM	clinvar_20150629	HGMD	esp6500siv2_all	1000g2015aug_all	1000g2015aug_afr	1000g2015aug_eas	1000g2015aug_eur	1000g_CDX	1000g_CHB	1000g_CHS	1000g_JPT	1000g_KHV	ExAC_ALL	ExAC_AFR	ExAC_AMR	ExAC_EAS	ExAC_FIN	ExAC_NFE	ExAC_OTH	ExAC_SAS	snp138	SIFT_score	SIFT_pred	Polyphen2_HDIV_score	Polyphen2_HDIV_pred	Polyphen2_HVAR_score	Polyphen2_HVAR_pred	LRT_score	LRT_pred	MutationTaster_score	MutationTaster_pred	MutationAssessor_score	MutationAssessor_pred	FATHMM_score	FATHMM_pred	PROVEAN_score	PROVEAN_pred	VEST3_score	CADD_raw	CADD_phred	DANN_score	fathmm-MKL_coding_score	fathmm-MKL_coding_pred	MetaSVM_score	MetaSVM_pred	MetaLR_score	MetaLR_pred	integrated_fitCons_score	integrated_confidence_value	GERP++_RS	phyloP7way_vertebrate	phyloP20way_mammalian	phastCons7way_vertebrate	phastCons20way_mammalian	SiPhy_29way_logOdds	GO_BP	GO_CC	GO_MF	KEGG_PATHWAY	REACTOME_PATHWAY	chrome	POS	ref	alt	qua	INFO	FORMAT	sample	sequence	sequence1	sequence2	postion	Hits	DP	FlankSeqQuality	Annover_fre	Variant Read Fre"."\t"."FP_result";
###"Chr"."\t"."Start"."\t"."End"."\t"."Ref"."\t"."Alt"."\t"."Func.refGene"."\t"."Gene.refGene"."\t"."GeneDetail.refGene"."\t"."ExonicFunc.refGene"."\t"."AAChange.refGene"."\t"."cytoBand"."\t"."genomicSuperDups"."\t"."OMIM"."\t"."clinvar_20150629"."\t"."HGMD"."\t"."esp6500siv2_all"."\t"."1000g2015aug_all"."\t"."1000g2015aug_afr"."\t"."1000g2015aug_eas"."\t"."1000g2015aug_eur"."\t"."1000g_CDX"."\t"."1000g_CHB"."\t"."1000g_CHS"."\t"."1000g_JPT"."\t"."1000g_KHV"."\t"."ExAC_ALL"."\t"."ExAC_AFR"."\t"."ExAC_AMR"."\t"."ExAC_EAS"."\t"."ExAC_FIN"."\t"."ExAC_NFE"."\t"."ExAC_OTH"."\t"."ExAC_SAS"."\t"."snp138"."\t"."SIFT_score"."\t"."SIFT_pred"."\t"."Polyphen2_HDIV_score"."\t"."Polyphen2_HDIV_pred"."\t"."Polyphen2_HVAR_score"."\t"."Polyphen2_HVAR_pred"."\t"."LRT_score"."\t"."LRT_pred"."\t"."MutationTaster_score"."\t"."MutationTaster_pred"."\t"."FATHMM_score"."\t"."FATHMM_pred"."\t"."PROVEAN_score"."\t"."PROVEAN_pred"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH"."\t"."ExAC_OTH";
#print $taitou;
#print FILOUT "$taitou\n";
$fin1=~s/\n/@@@@/gm;   ####这样替换把想分析的那部分拿出来做一块单独放到一个元素中...原来这么简单，我折腾了那么久。还是要先找好规律，不用必须按行来分，按块来分也可以哒。
my @splitresults1=split(/@@@@/,$fin1); 

foreach  (@splitresults1)
    {
	my @file_line = split('\t', $_);
	my $functional_result="FP_result";
    ##my $delt_count = 0;
	   my $adelt_count = 0;	 
	##my $bdelt_count = 0;
	##Functional#############
	if ($file_line[8]=~/stopgain/ or $file_line[8]=~/frameshift/ or $file_line[8]=~/stoploss/)
		    {
			$functional_result="H";
			#print "$functional_result\n";
		    }
	elsif($file_line[8]=~/^\.$/) 
			{
			$functional_result="M";
			#print "$functional_result\n";
			}
	elsif($file_line[8]=~/unknown/) 
	        {$functional_result="M";}
			
    elsif ($file_line[8]=~/nonsynonymous/)
		 {
		 ##SIFT#############
	     if ($file_line[35]){if ($file_line[35] eq "D"){$adelt_count++;}else{}}else{}		
		 ##POLYphen_HDIV##########
		 if ($file_line[37]){if ($file_line[37] eq "D" || $file_line[37] eq "P"){$adelt_count++;}else{}}else{}
		 ##MutationTaster_pred#############
		 if ($file_line[43]){if ($file_line[43] eq "D" || $file_line[43] eq "A"){$adelt_count++;}else{}}else{}
		 ##CADD#########
		 if ($file_line[52]){if($file_line[52] ge 15){$adelt_count++;}else{}}else{}
		 ################
	     if($adelt_count==4){$functional_result="H";}
	     if($adelt_count>=2 && $adelt_count<4){$functional_result="M";}
	     if($adelt_count<2 ){$functional_result="L";}
		 }
	else {}
    print "$functional_result";
    print FILOUT "$_";
	print FILOUT "$functional_result\n";	
	}
close FILE1;
close FILOUT;	
	