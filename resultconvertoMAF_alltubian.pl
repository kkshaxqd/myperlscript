#! /usr/bin/perl -w
use strict;
#use like this :  perl resultconverttoMAF.pl  <inputfile> <inputfile's samplename> <outfile>
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $samplename=$ARGV[1];   #加上样本的名字
my $dest_file=$ARGV[2];   #想输出的文件的名字
open (IN, "<$filename1") || die "use like this :  perl resultconverttoMAF.pl  <inputfile> <inputfile's samplename> <outfile>";
open (OUT, ">$dest_file") || die "use like this :  perl resultconverttoMAF.pl  <inputfile> <inputfile's samplename> <outfile>";

#Hugo_Symbol	Entrez_Gene_Id	Center	NCBI_Build	Chromosome	Start_Position	End_Position	Strand	Variant_Classification	Variant_Type	Reference_Allele	Tumor_Seq_Allele1	Tumor_Seq_Allele2	dbSNP_RS	Tumor_Sample_Barcode
#JAK1	1000	WUGSC	GRCh37	chr1	65332611	65332611	+	Missense_Mutation	SNP	C	C	T	novel	SampleG4A1

#print OUT "Hugo_Symbol\tEntrez_Gene_Id\tCenter\tNCBI_Build\tChromosome\tStart_Position\tEnd_Position\tStrand\tVariant_Classification\tVariant_Type\tReference_Allele\tTumor_Seq_Allele1\tTumor_Seq_Allele2\tdbSNP_RS\tTumor_Sample_Barcode\n"; 
my ($hugosymbol,$refallele,@info,$chr,$start,$stop,$varianttype,$variantclass,$tumorseqallele1,$tumorseqallele2);
while(<IN>)
{
chomp;
next if /GeneDetail\.refGene/;
@info=split/\t/,$_;
if($info[8]=~/unknown/||$info[5]=~/ncRNA/|| $info[5]=~/m\;d/ || $info[5]=~/5\;U/ || $info[5]=~/stream/){next;}
if($info[6]=~/\,/|| $info[6]=~/NONE/ || $info[6]=~/\./){next;}
if ($info[6]){$hugosymbol=$info[6]}
my $Egeneid="1000";
my $center="WUGSC";
my $ncbi_build="GRCh37";
if ($info[0]&&$info[0]=~/chr/){$chr=$info[0]}
if ($info[1]&&$info[1]=~/\d+/){$start=$info[1]}
if ($info[2]&&$info[2]=~/\d+/){$stop=$info[2]}
my $strand="+";


if($info[3]&&$info[4])
	{
	if($info[3]=~/\w/&&$info[4]=~/\w/&&$info[3]!~/$info[4]/){$varianttype="SNP"}
	if($info[3]=~/\-/&&$info[4]=~/\w+/){$varianttype="INS"}
	if($info[3]=~/\w+/&&$info[4]=~/\-/){$varianttype="DEL"}
	$refallele=$info[3];
	$tumorseqallele1=$info[3];
	$tumorseqallele2=$info[4];
	}
if($info[5]=~/intergenic/){$variantclass="IGR"}
elsif($info[5]=~/intronic/){$variantclass="Intron"}
elsif($info[5]=~/UTR3/){$variantclass="3'UTR"}
elsif($info[5]=~/UTR5/){$variantclass="5'UTR"}
elsif($info[5]=~/exonic/ or $info[5]=~/splicing/)
{
if ($info[8])
	{
	if($info[8]=~/\./){$variantclass="Splice_Site"}
	if($info[8]=~/nonsynonymous\sSNV/){$variantclass="Missense_Mutation"}
	if($info[8]=~/frameshift\sdeletion/){$variantclass="Frame_Shift_Del";$varianttype="DEL"}
	if($info[8]=~/frameshift\sinsertion/){$variantclass="Frame_Shift_Ins";$varianttype="INS"}
	if($info[8]=~/nonframeshift\sinsertion/){$variantclass="In_Frame_Ins";$varianttype="INS"}
	if($info[8]=~/nonframeshift\sdeletion/){$variantclass="In_Frame_Del";$varianttype="DEL"}
	if($info[8]=~/stopgain/){$variantclass="Nonsense_Mutation"}
	if($info[8]=~/stoploss/){$variantclass="Nonsense_Mutation"}
	if($info[8]=~/synonymous\sSNV/){$variantclass="Silent"}
	}
}
	
my $dbSNP_RS="novel";	

my $Tumor_Sample_Barcode=$samplename;

print OUT "$hugosymbol\t$Egeneid\t$center\t$ncbi_build\t$chr\t$start\t$stop\t$strand\t$variantclass\t$varianttype\t$refallele\t$tumorseqallele1\t$tumorseqallele2\t$dbSNP_RS\t$Tumor_Sample_Barcode\n";

}
close IN;
close OUT;
