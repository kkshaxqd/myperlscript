#!usr/bin/perl
use strict;
use warnings;
oepn STUDY, < , "study_field.txt" or die;
open COMPL, >, "compleited.txt" or die;
open COMPL2, >, "compleited2.txt" or die;
my @splitresults = split(/^\s+$/,STUDY); #首先将文件按空行分割
foreach  (@splitresults) {
	if ($_=~/(Recruitment:)\s+(Completed)/) {
		push my @results,"$_\n";                #将匹配Recruitment:              Completed的字符串加入结果中
	    print COMPL "$_";            #将匹配的放入COMPL里？
	}
}
print COMPL2 "@results";
close STUDY;
close COMPL;
close COMPL2;
