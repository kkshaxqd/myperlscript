#!usr/bin/perl -w

while(0){use strict;
$/=undef;
open FILE,'<', 'shuru.txt'  or die "Can't open file:$!";
open FOUT,'>', 'completed.txt' or die "Can't open file:$!";
#my $filedata=glob("shuru.txt");就提取了个shuru.txt文件名
my $fin=<FILE>;
$/="\n";
my @splitresults = split(/\A\s+\z/,$fin); #首先将文件按空行分割，按这一命令却并没成功。。。
#print "@splitresults"; 能打出来全部内容，但根本没有分割说明
foreach  (@splitresults) {
	
	if ($_=~/(Completed)/) {
		              
	    print FOUT "$_\n";            #将匹配的放入COMPL里？
	}
}

close FILE;
close FOUT;
}

 
#!perl -w
#open IN,"<","empty.pl";
# undef $/;关键是一次读入多行 才有可能多行替换 不然 你的数据行只有一行 怎么能多行操作?
# while (<IN>) {
#   chomp;
#     s/^\s*$/<p>/mg;
#     print;
# }

#writer:zhangqsh@gentalker.com;2016-03-29;

#!usr/bin/perl -w
use strict;
$/=undef;
open FILE,'<', 'shuru.txt'  or die "Can't open file:$!";
open FOUT,'>', 'completed-and-terminated.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my @splitresults=split(/ABQ/,$fin);

foreach  (@splitresults) {
	if ($_=~/(Recruitment:)\s+(Completed)|(Recruitment:)\s+(Terminated)/mg) {
		print FOUT "$_\n";
	}
}
close FILE;
close FOUT;