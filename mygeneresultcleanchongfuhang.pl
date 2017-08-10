#!perl -w
 
open FH1,"human_gene_annotion_clean2016073015_clean_clean.txt";
open FH2,">human_gene_annotion_clean2016073015_clean_clean_clean.txt";
 
$temp = "";
while(<FH1>)
{
    if(not $temp eq $_)     ####如果不等就打印
    {
        print FH2;
        $temp = $_;
    }
}
 
close FH1;
close FH2;