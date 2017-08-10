#!/usr/bin/perl -w
use strict;
my $filename1=$ARGV[0];   #不用每次改名称，在perl 输入命令时改 第一个输入文件名内容
my $dest_file=$ARGV[1];   #想输出的文件的名字
open (IN, "<$filename1") || die ;
open (OUT, ">$dest_file") || die ;
#my $chr;
# while(<IN>)
# {
# chomp;
# my @info=split/\t/,$_;

# if($info[0]=~/chr(.*)/){$chr=$1}

# my $biaozhun=sprintf("%d",($info[1]+$info[2])/2);

# print OUT "WESID\t$chr\t$biaozhun\n";


# }


while(<IN>)
{
chomp;
if($_=~/chr(\d+|[X])\:(\d+)\-(\d+)/)
{my $chr=$1;
my $start=$2;
my $stop=$3;
my $biaozhun=sprintf("%d",($start+$stop)/2);

print OUT "EXOMEID\t$chr\t$biaozhun\n";
}

}

