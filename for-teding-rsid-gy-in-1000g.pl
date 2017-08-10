#!/usr/bin/perl -w
#求千人基因组中两个特定位置基因的中国人的信息
#writer:张桥石   514079685@qq.com;2017-03-03;
use strict;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (FILE1, "<$filename1") || die "Could not read from $filename1, program halting.";
open (FILOUT, ">$dest_file") || die "Could not read from $dest_file, program halting.";
my (@fenzu0,@fenzu);
while(<FILE1>){
chomp;
next if(/^##/);
if (/^#CHROM/){@fenzu0=split /FORMAT\t/,$_;print FILOUT "rsID\t$fenzu0[1]\n";}
@fenzu=split /GT\t/,$_;
if ($fenzu[0]=~/rs2239785\t/){print FILOUT "rs2239785\t$fenzu[1]\n";}  ##注意必须精准匹配才行
if ($fenzu[0]=~/rs136175\t/){print FILOUT "rs136175\t$fenzu[1]\n";}
if ($fenzu[0]=~/rs136176\t/){print FILOUT "rs136176\t$fenzu[1]\n";}
if ($fenzu[0]=~/rs1005570\t/){print FILOUT "rs1005570\t$fenzu[1]\n";}
if ($fenzu[0]=~/rs2413396\t/){print FILOUT "rs2413396\t$fenzu[1]\n";}
if ($fenzu[0]=~/rs80338826\t/){print FILOUT "rs80338826\t$fenzu[1]\n";}
if ($fenzu[0]=~/rs3752462\t/){print FILOUT "rs3752462\t$fenzu[1]\n";}
if ($fenzu[0]=~/rs11089788\t/){print FILOUT "rs11089788\t$fenzu[1]\n";}
if ($fenzu[0]=~/rs2269529\t/){print FILOUT "rs2269529\t$fenzu[1]\n";}
}

close FILE1;
close FILOUT;










