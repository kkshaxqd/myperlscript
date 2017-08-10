#!/usr/bin/perl 
#处理drug-bank的数据，将药物按基因分开 #./drug-bank-fenhang-by-gene.pl drugbank-rawdata.txt > drugbank_data-1.txt
use strict;

my $x1 = $ARGV[0]; 
my (@file_line,@gene_name,@gene_locus,@specific_function,@general_function,@target_action,@target_name,%fenyao);
open INFILE1, "$x1" or die "couldn't open $x1\n";

while (<INFILE1>)
{
	 chomp;
	 @file_line=split("\t",$_);
	 #chomp(@file_line);
	 if ($_=~/Drugbank\-id/){print "$_\n"}
	 #Drugbank-id	Drugname	Description	Target gene-name	Target gene-locus	Target name	Target action	Target general-function	Target specific-function	Indication	Pharmacodynamics	Toxicity
	 else 
	{
		if ($file_line[3]&&$file_line[3]=~/;/)  ##所以之前的错误与偏差是因为有的行并一定有第七列。需要对数据进行先处理。现对数据进行处理修正。
		{
		@gene_name=split(";",$file_line[3]);
		@gene_locus=split(";",$file_line[4]);
		@specific_function=split(";",$file_line[8]);
		@general_function=split(";",$file_line[7]);
		@target_action=split(";",$file_line[6]);
		@target_name=split(";",$file_line[5]);
			for my $i (0..$#gene_name)
			{
				if ($gene_name[$i]=~/\S/){}else{$gene_name[$i]=".";}
				if ($gene_locus[$i]=~/\S/){}else{$gene_locus[$i]=".";}
				if ($specific_function[$i]=~/\S/){}else{$specific_function[$i]=".";}
				if ($general_function[$i]=~/\S/){}else{$general_function[$i]=".";}
				if ($target_action[$i]=~/\S/){}else{$target_action[$i]=".";}
				if ($target_name[$i]=~/\S/){}else{$target_name[$i]=".";}           ##这样就行了。
				# if ($gene_name[$i]=~/[^\S]+\s[^\S]+/){$gene_name[$i]=".";}
				# if ($gene_locus[$i]=~/[^\S]+\s[^\S]+/){$gene_locus[$i]=".";}
				# if ($specific_function[$i]=~/[^\S]+\s[^\S]+/){$specific_function[$i]=".";}
				# if ($general_function[$i]=~/[^\S]+\s[^\S]+/){$general_function[$i]=".";}
				# if ($target_action[$i]=~/[^\S]+\s[^\S]+/){$target_action[$i]=".";}
				# if ($target_name[$i]=~/[^\S]+\s[^\S]+/){$target_name[$i]=".";}
		print $file_line[0]."\t".$file_line[1]."\t".$file_line[2]."\t".$gene_name[$i]."\t".$gene_locus[$i]."\t".$target_name[$i]."\t".$target_action[$i]."\t".$general_function[$i]."\t".$specific_function[$i]."\t".$file_line[9]."\t".$file_line[10]."\t".$file_line[11]."\n";
			}
		 
		# @gene_locus=split(";",$file_line[8]);
		# @specific_function=split(";",$file_line[6]);
		# @general_function=split(";",$file_line[5]);
		# @target_action=split(";",$file_line[4]);
		# @target_name=split(";",$file_line[3]);
		}
		else 
		{
			if ($file_line[3]&&$file_line[3]!~/;/)
			{
		print $file_line[0]."\t".$file_line[1]."\t".$file_line[2]."\t".$file_line[3]."\t".$file_line[4]."\t".$file_line[5]."\t".$file_line[6]."\t".$file_line[7]."\t".$file_line[8]."\t".$file_line[9]."\t".$file_line[10]."\t".$file_line[11]."\n"; 
			}
		
		}
	
	}
}
close INFILE1;