#!/usr/bin/perl -w
use strict;
#use like this :  perl xhmmcnvfortumoranalysescirpt-02.pl <input cnv.file> <output novelcnvfile>
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (IN, "<$filename1") || die "use like this :   perl xhmmcnvfortumoranalysescirpt-02.pl <input cnv.file> <output novelcnvfile>\n";
open (OUT, ">$dest_file") || die "use like this :   perl xhmmcnvfortumoranalysescirpt-02.pl <input cnv.file> <output novelcnvfile>\n";
#open (TEMP1,">xhmmcnvNA.txt");
#open (TEMP2,">xhmmcnvTA.txt");

my ($sample0,%paichu,%bidui,@paichucnvregion,@biduicnvregion01,@jutiregion,$tachr,$tastart,$tastop,@jutina,$nachr,$nastart,$nastop);
##先构建NA排除的CNV合集，然后mapping TA中的CNV，如果匹配上或者在其内，那么排除

while(<IN>)
{
chomp;
next if /SAMPLE|GENE/;
my @info=split/\t/,$_;
my $sample=$info[0];
if($sample=~/(.*)\-/){$sample0=$1}
my $chr=$info[1];
my $start=$info[2];
my $stop=$info[3];
my $type=$info[4];
my $kb=$info[7];


if($sample=~/\-NA/){
	if($paichu{$sample0}){
		$paichu{$sample0}=$paichu{$sample0}."\n".$chr.":".$start.":".$stop;
		}
	else{$paichu{$sample0}=$chr.":".$start.":".$stop;}	
	}

if($sample=~/\-TA/){
	if($bidui{$sample0}){
		$bidui{$sample0}=$bidui{$sample0}."\n".$_;
		}
	else{$bidui{$sample0}=$_;}	
	}
	
}

foreach my $key1 (%paichu)
{
@paichucnvregion=split /\n/,$paichu{$key1};
@biduicnvregion01=split /\n/,$bidui{$key1};
my $noveltacnv=0;
for my $temp0 ( 0..@biduicnvregion01-1)
	{
	@jutiregion=split /\t/, $biduicnvregion01[$temp0];
	$tachr=$jutiregion[1];
	$tastart=$jutiregion[2];
	$tastop=$jutiregion[3];
	my $taflag=0;
	for my $temp1 (0..@paichucnvregion-1)
		{
		@jutina=split /\:/,$paichucnvregion[$temp1];
		$nachr=$jutina[0];
		$nastart=$jutina[1];
		$nastop=$jutina[2];

		if($tachr=~/$nachr/)
			{
			
			if ($tastart<=$nastop && $tastop>=$nastart) {$taflag++}  #匹配上什么也不做，排除  
			#if ($tastart>=$nastart && $tastop<=$nastop) {$taflag++}  #匹配上什么也不做，排除
			#elsif($tastart<$nastart && $tastop<$nastop && $tastop>$nastart ){$flag++}  #&& (($tastop-$nastart)>=(($nastop-$nastart)*0.2))  #不算占比了，只要有交集就不要
			#elsif($tastart>$nastart && $tastop>$nastop && $tastart<$nastop ){$flag++}  #&& (($nastop-$tastart)>=(($nastop-$nastart)*0.2))
			#elsif($tastart<$nastart && $tastop>$nastop ){$flag++}  #&& (($nastop-$nastart)>=(($tastop-$tastart)*0.2))
			
			}
		
		}
		if($taflag){}
		else{
			$noveltacnv++;
			print OUT "$key1\t$noveltacnv\t$biduicnvregion01[$temp0]\n";
			}	
	}

}

close IN;
close OUT;
	
	
	