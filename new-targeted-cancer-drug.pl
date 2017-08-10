#!usr/bin/perl -w
#2016-03-30 筛临床新药。
#writer:zhangqsh@gentalker.com;


use strict;
$/=undef;
open FILE,'<', 'targeted-clinical-phases-cancer-drug.txt'  or die "Can't open file:$!";
open FOUT,'>', 'new-clinical-targeted-cancer-drug-2.txt' or die "Can't open file:$!";
chomp(my $fin=<FILE>);
$fin=~s/^\s*$/ABQ/gm;
my @splitresults=split(/ABQ/,$fin);
my $count=0;
my $sum=0;
foreach  (@splitresults) {
	if ($_=~/Drug:/) {
	if ($_=~/imatinib|carboplatin|cisplatin|oxaliplatin|cyclophosphamide|lfosfamide|daunorubicin|doxorubicin|epirubicin|ldarubicin|bisantrene|methotrexate|capecitabine|5-FU|cytarabine|paclitaxel|vincristine|docetaxel|etoposide|gemcitabine|tamoxifen|letrozole|anastrozole|lrinotecan|mercaptopurine|azathioprine|pemetrexed|everolimus|temsirolimus|sirolimus|trastuzumab|pazopanib|nilotinib|vemurafenib|dabrafenib|trametinib|cabozantinib|alemtuzumab|cetuximab|bevacizumab|ponatinib|vandetanib|rituximab|panitumumab|bosutinib|crizotinib|lmatinib|regorafenib|erlotinib|gefitinib|afatinib|lapatinib|sunitinib|sorafenib|vismodegib|ruxolitinib/ximg) 
		{
		$sum++;
	}
	else{
		print FOUT "This is ". ("$count"+1)."\n";
		print FOUT "$_\n";
		$count++;
	}
	}
}
print FOUT "The other targeted drugs for targeted therapy are $sum\n";
print FOUT "The total number of new drugs are $count.\n";
close FILE;
close FOUT;
#更好的方法是智能匹配，建立一个数组，包含非临床的药物名，然后匹配。/智能匹配不行？$_~~ @_ 并不是让字符串中有内容匹配数组里的