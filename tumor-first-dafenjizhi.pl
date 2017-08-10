#!/usr/bin/perl -w
####修改者，张桥石，514079685@qq.com 2016-11-28#####
###########################
####换种写法，原来的写法最后输出的结果列不统一，这样不好，原因可能是新增的注释的问题，那些空缺的都没有了？不是，是脚本的问题，估计这样写把一部分空的给删除了。
##针对版本为2017-04-30版本的FFPE分析流程
use strict;

my @first;
my $mb;

my @common_snps;
my $x1 = $ARGV[0];
my $functional_result;
my $adelt_count=0;	
open INFILE3, "$x1" or die "couldn't open $_\n";
while (<INFILE3>)
    {
	chomp;
if ($_=~/Start/){ $functional_result="First_scoring_result"; print "$_"\t"$functional_result\n"; }
else {
my @file_line = split('\t', $_);
    if ($file_line[8]=~/stopgain/ or $file_line[8]=~/frameshift/ or $file_line[8]=~/stoploss/)
		     {
			 $functional_result="HH";
			 #print "$functional_result\n";
         if ($file_line[71] ){if($file_line[71]=~/COS/  ){$functional_result="HHH";}else{}}else{}

         if ($file_line[72] ){if($file_line[72]=~/pathogenic/i ){$functional_result="HHH";}else{}} else{}  ###满足LOF加COSMIC或CLINVAR有结果。
		 if ($file_line[71] and $file_line[72]){if ($file_line[72]=~/pathogenic/ and $file_line[71]=~/COS/) {$functional_result="HHHH";}else{}}else{}
		     }
    elsif($file_line[8]=~/unknown/) {$functional_result="M";}
    elsif ($file_line[8]=~/nonsynonymous/)
		  {         	  
		 ##SIFT#############
	     if ($file_line[15]){if ($file_line[15] eq "D"){$adelt_count++;}else{}}else{}		
		 ##POLYphen_HVAR##########
		 if ($file_line[19]){if ($file_line[19] eq "D" || $file_line[19] eq "P"){$adelt_count++;}else{}}else{}
		 ##MutationTaster_pred#############
		 if ($file_line[23]){if ($file_line[23] eq "D" || $file_line[23] eq "A"){$adelt_count++;}else{}}else{}
		 ##CADD#########
		 if ($file_line[32]){if($file_line[32] ge 15){$adelt_count++;}else{}}else{}
		 ################
	     if($adelt_count==4){$functional_result="Hpred";}
	     if($adelt_count>=2 && $adelt_count<4){$functional_result="M";}
	     if($adelt_count<2 ){$functional_result="L";}
		 #####  clinvar
		 if ($file_line[72] ){if ($file_line[72]=~/pathogenic/i ){$functional_result="Hcli";}else{}}else{}
		  #####	COSMIC	 
	     if ($file_line[71] ){if ($file_line[71]=~/COS/ ){$functional_result="Hcos";} else{}}else{}
         if ($file_line[71] and $file_line[72]){if ($file_line[72]=~/pathogenic/i and $file_line[71]=~/COS/) {$functional_result="HHHH";}else{}}else{}
         }
    else {$functional_result="L";}
    print "$_"\t"$functional_result\n";
      }
	}
close INFILE3;












	
