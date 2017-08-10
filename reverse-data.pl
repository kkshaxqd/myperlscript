#!usr/bin/perl -w
#2016-03-29 反转顺序 
#writer:zhangqsh@gentalker.com;

use strict;
$/=undef;
open FILE,'<', 'new-clinical-targeted-cancer-drug.txt'  or die "Can't open file:$!";
open FOUT,'>', 'reverse-new-clinical-targeted-cancer-drug.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my @splitresults=split(/ABQ/,$fin);
@splitresults=reverse(@splitresults);
print FOUT "@splitresults";
close FILE;
close FOUT;
#2016-03-30号反转另一个文件。