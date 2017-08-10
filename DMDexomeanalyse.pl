#!/usr/bin/perl -w

#分析DMD基因的测序深度然后，确定判断是否有CNV缺失情况
#包含每个外显子区域前后50bp左右位置的测序深度，首先使用samtools depth -a -r bed文件，外显子区域起始和结束  -f bam文件list > 输出。
#1bed文件好像只是根据第二列和第三列，起始终止位置，然后计算起始和终止之间全部区域的reads数。 所以，首先需要把bed文件处理下，HGMD中DMD基因
#NM号是NM_004006  ，处理这个转录本的外显子区域。
#现在已经得到DMD每一外显子每一行的坐标
#然后分别读取每一行，分别计算该区域深度
#计算的深度结果，然后可视化深度结果
#####  后面发现，samtools有其他命令可以更简单分析一些，samtools tview MB_1294_N_P0061.R1_sort.bam.dedupped.bam \
######                                                 /mnt/home/qsZhang/zqs/software/IMPACT/hg19_index/hg19.fa -p chrX:31137344-31140047
#######         比如这个命令，可以实现igv一样的功能，直接看相应区域的覆盖度就好了。
#####  这个命令， samtools bedcov  DMD79exomecor.txt MB_1294_N_P0061.R1_sort.bam.dedupped.bam  可以根据给出的外显子区域 坐标，得到该区域碱基的覆盖度情况。
use strict;

my $input=$ARGV[0];

my $output=$ARGV[1];

my $ssss= system(" samtools bedcov  DMD79exomecor.txt MB_1294_N_P0061.R1_sort.bam.dedupped.bam > DMDexome-covanalyse.txt");  



