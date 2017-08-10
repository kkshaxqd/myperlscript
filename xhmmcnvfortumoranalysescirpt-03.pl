#!/usr/bin/perl -w
use strict;
use List::Util qw/max min maxstr/;  #perl中数组最大最小值模块
#use like this :  perl xhmmcnvfortumoranalysescirpt-03.pl <input 02novelcnv.file> #<output 03highfreqcnvfile>
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (IN, "<$filename1") || die "use like this :   perl xhmmcnvfortumoranalysescirpt-03.pl <input 02novelcnv.file> <output 03highfreqcnvfile>\n"; 
open (OUT, ">$dest_file") || die "use like this :   perl xhmmcnvfortumoranalysescirpt-03.pl <input 02novelcnv.file> <output 03highfreqcnvfile>\n";

open (TEMP1,">xhmmcnvtempfile");
#open (TEMP2,">xhmm.segmentedFile");

#my $sum=`wc -c $filename1 |cut -d ' ' -f1 |bc `;



my (%num,%sample,%constract);
while(<IN>)
{
chomp;

my @info=split/\t/,$_;
my $sample=$info[0];
my $chr=$info[3];
my $start=$info[4];
my $stop=$info[5];
my $type=$info[6];
my $targetnum=$info[7];
my $KB=$info[9];
my $gene=$info[10];
for my $gi (10..@info-1)
{if ($gi==10){$gene=$info[10]}else{$gene=$gene."|".$info[$gi]}}
my $id=$sample."\t".$chr."\t".$start."\t".$stop."\t".$type;
my $mapid=$chr."\t".$start."\t".$stop."\t".$type;

print TEMP1 "$chr\t$start\t$stop\t$type\t$sample\t$gene\n";

$constract{$mapid}=$KB."\t".$gene;
#构建比对集
#$bidui{$id}=$gene;
#构建mapping集
#$mapping{$id}=$_;
}
close TEMP1;
#构建旗帜cnv
my %cnvfsum;
my %cnvhebing;
my (@startzu,@stopzu,@genekb);
open (TEMP1,"<xhmmcnvtempfile");
while(<TEMP1>)
{
chomp;
my @temp1=split/\t/,$_;
my $biduichr=$temp1[0];
my $biduistart=$temp1[1];
my $biduistop=$temp1[2];
my $biduitype=$temp1[3];
my $cid=$biduichr."\t".$biduistart."\t".$biduistop."\t".$biduitype;
@startzu=();          #每次空数组
@stopzu=();
@genekb=();
#if($constract{$cid})   #比对cnv区域集合
#{
 foreach my $key1 (keys %constract)
 {
 my @temp2=split/\t/,$key1;
 if($biduichr=~/$temp2[0]/&&$biduitype=~/$temp2[3]/)
	{
	if($temp2[1]<=$biduistop && $temp2[2]>=$biduistart)   #核心算法
		{
		push (@startzu,$temp2[1]);
		push (@stopzu,$temp2[2]);
		push (@genekb,$constract{$key1})
		}
	}
 }
#}
#my  $startnew= max @startzu;  #取最小交集的算法可能并不好。仔细分析的话，出现终点大于起点，最小终点和最大起点相等的情况都是要考虑的
#my  $stopnew= min @stopzu;
#另一种方法，取最长集，这样也不会出现起点大于终点的情况
my $startnew=min @startzu;
my $stopnew=max @stopzu;
my $hebingnew=maxstr @genekb;
#这样得到的终点会小于起点，但都是覆盖同样区域的,而且一次大，次次也都是大的
 #if($stopnew<=$biduistop && $startnew>=$biduistart)
 #{
 # if($startnew>$stopnew)
# {my $cnv=$biduichr.":".$stopnew."-".$startnew."\t".$biduitype;
 # $cnvfsum{$cnv}++;
 # }
# elsif($startnew<$stopnew){ my $cnv=$biduichr.":".$startnew."-".$stopnew."\t".$biduitype;
 # $cnvfsum{$cnv}++;
 # }
 #}
 my $cnv=$biduichr.":".$startnew."-".$stopnew."\t".$biduichr."\t".$startnew."\t".$stopnew."\t".$biduitype;
 $cnvfsum{$cnv}++;
 $cnvhebing{$cnv}=$hebingnew;
}
 
print OUT "CNVregion\tchr\tcnvstart\tcnvstop\tType\tcnvNum\tcnvFreq\tmaxKB\tmaxGENE\n";
 
foreach my $key2 (sort{$cnvfsum{$a}<=>$cnvfsum{$b}} keys %cnvfsum)
{
my $cnvfreq=sprintf("%.2f",$cnvfsum{$key2}/12);  #这次有12个样本
print OUT "$key2\t$cnvfsum{$key2}\t$cnvfreq\t$cnvhebing{$key2}\n";
}

close TEMP1;
close IN;
close OUT;