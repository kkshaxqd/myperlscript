#! /usr/bin/perl -w
use strict;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (IN, "<$filename1") || die ;
open (OUT, ">$dest_file") || die ;

print OUT "GENE\tYCM-DF\tWXH-DF\tFJY-DF\tCTX-DF\tDLJ-DF\tLQQ-DF\tYCJ-DF\tCXY-FF\tNL-FF\tCJL-FF\tZCY-FF\tZLL-FF\n";
my %hash;
my (%YCM,%CXY,%NL,%WXH,%FJY,%CTX,%DLJ,%LQQ,%YCJ,%CJL,%ZCY,%ZLL);

while(<IN>)
{
chomp;
next if /Number/;
my @info=split/\t/,$_;
my $sample=$info[2];
my $Number=$info[0];
my $gene=$info[1];
# if($sample=~/YCM-DF/){$hash{$gene.":".YCM-DF}=$Number} #构建二维哈希 $hash{$key1.":".$key2} = $value;
# if($sample=~/CXY-FF/){$hash{$gene.":".CXY-FF}=$Number}
# if($sample=~/NL-FF/){$hash{$gene.":".NL-FF}=$Number}
# if($sample=~/WXH-DF/){$hash{$gene.":".WXH-DF}=$Number}
# if($sample=~/FJY-DF/){$hash{$gene.":".FJY-DF}=$Number}
# if($sample=~/CTX-DF/){$hash{$gene.":".CTX-DF}=$Number}
# if($sample=~/DLJ-DF/){$hash{$gene.":".DLJ-DF}=$Number}
# if($sample=~/LQQ-DF/){$hash{$gene.":".LQQ-DF}=$Number}
# if($sample=~/YCJ-DF/){$hash{$gene.":".YCJ-DF}=$Number}
# if($sample=~/CJL-FF/){$hash{$gene.":".CJL-FF}=$Number}
# if($sample=~/ZCY-FF/){$hash{$gene.":".ZCY-FF}=$Number}
# if($sample=~/ZLL-FF/){$hash{$gene.":".ZLL-FF}=$Number}
#不加后面的也可以，不过哈希为空。
if($sample=~/YCM-DF/){$YCM{$gene}=$Number}elsif($YCM{$gene}){} else{$YCM{$gene}=0}
if($sample=~/CXY-FF/){$CXY{$gene}=$Number}elsif($CXY{$gene}){} else{$CXY{$gene}=0}
if($sample=~/NL-FF/){$NL{$gene}=$Number}elsif($NL{$gene}){} else{$NL{$gene}=0}
if($sample=~/WXH-DF/){$WXH{$gene}=$Number}elsif($WXH{$gene}){} else{$WXH{$gene}=0}
if($sample=~/FJY-DF/){$FJY{$gene}=$Number}elsif($FJY{$gene}){} else{$FJY{$gene}=0}
if($sample=~/CTX-DF/){$CTX{$gene}=$Number}elsif($CTX{$gene}){} else{$CTX{$gene}=0}
if($sample=~/DLJ-DF/){$DLJ{$gene}=$Number}elsif($DLJ{$gene}){} else{$DLJ{$gene}=0}
if($sample=~/LQQ-DF/){$LQQ{$gene}=$Number}elsif($LQQ{$gene}){} else{$LQQ{$gene}=0}
if($sample=~/YCJ-DF/){$YCJ{$gene}=$Number}elsif($YCJ{$gene}){} else{$YCJ{$gene}=0}
if($sample=~/CJL-FF/){$CJL{$gene}=$Number}elsif($CJL{$gene}){} else{$CJL{$gene}=0}
if($sample=~/ZCY-FF/){$ZCY{$gene}=$Number}elsif($ZCY{$gene}){} else{$ZCY{$gene}=0}
if($sample=~/ZLL-FF/){$ZLL{$gene}=$Number}elsif($ZLL{$gene}){} else{$ZLL{$gene}=0}
$hash{$gene}=1;
}
#foreach my $key2 (sort {$hash{$key1}->{$b}<=>$hash{$key1}->{a}} keys %{$hash{$key1}}) #对value值按照数字大小进行逆序排序

#foreach my $key2 (sort {$a<=>$b} keys %{$hash{$key1}})

 # #foreach my $key1 (keys %hash)
 # {
 # my $hash2 = $hash{$key1};
 # foreach my $key2 (sort{$hash2->{$b}<=>$hash2->{a}} keys %$hash2)
 # {
 # print $key1.”\t”.$key2.”\t”.$hash2->{$key2}.”\t”;
 # }
 # }

foreach my $key (sort {$a<=>$b} keys %hash)
{

print OUT "$key\t$YCM{$key}\t$WXH{$key}\t$FJY{$key}\t$CTX{$key}\t$DLJ{$key}\t$LQQ{$key}\t$YCJ{$key}\t$CXY{$key}\t$NL{$key}\t$CJL{$key}\t$ZCY{$key}\t$ZLL{$key}\n";
#print OUT "$hash{$key1}{YCM-DF}\t$hash{$key1}{WXH-DF}\t$hash{$key1}{FJY-DF}\t$hash{$key1}{CTX-DF}\t$hash{$key1}{DLJ-DF}\t$hash{$key1}{LQQ-DF}\t$hash{$key1}{LQQ-DF}\t";
#GENE\tYCM-DF\tWXH-DF\tFJY-DF\tCTX-DF\tDLJ-DF\tLQQ-DF\tYCJ-DF\tCXY-FF\tNL-FF\tCJL-FF\tZCY-FF\tZLL-FF\n
}
close IN;
close OUT;
