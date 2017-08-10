#!usr/bin/perl -w
#将json文件内数据提取转化为txt或exls能打开的那种格式
#writer:张桥石   514079685@qq.com;2016-08-02;
use strict;
$/=undef;
open FILE,'<', 'clinical.project-TCGA-LUSC.2016-07-04T06-32-48.024592.json'  or die "Can't open file:$!";
open FOUTC,'>', 'clinical.project-TCGA-LUSC-convertdata.txt' or die "Can't open file:$!";
my $fin=<FILE>;
$fin=~s/\]\n\s\s\},\s\n/@@@@/gm;
my @splitresults=split(/@@@@/,$fin);
  my $count=1;
  my $yihang=0;
  my $a=0;
  my $b=0;
  my $c=0;
  my $d=0;
  my $e=0;
  my $f=0;
  my $g=0;
  my $h=0;
  my $i=0;
  my $j=0;
  my $k=0;
  my $l=0;
  my $m=0;
  my $n=0;
  my $o=0;
  my $p=0;
  my $q=0;
  my $r=0;
  my $s=0;
  my $t=0;
  my $u=0;
  my $v=0;
  my $cida=0;
  my $cidb=0;
  my $cidc=0;
  my $cidd=0;
  my $cide=0;
  my $cidf=0;
  my $cidg=0;
  my $cidh=0;
  my $cidi=0;
  my $cidj=0;
  my $cidk=0;
  my $exa=0;
  my $exb=0;
  my $exc=0;
  my $exd=0;
  my $exe=0;
  my $exf=0;
  my $exg=0;
  my $exh=0;
  my $exi=0;
  my $exj=0;
  my $exk=0;
  my $exl=0;
my $col_name="diagnoses"."\t"."classification_of_tumor"."\t"."last_known_disease_status"."\t"."updated_datetime"."\t"."primary_diagnosis"."\t"."submitter_id"."\t"."tumor_stage"."\t"."age_at_diagnosis"."\t"."vital_status"."\t"."morphology"."\t"."days_to_death"."\t"."days_to_last_known_disease_status"."\t"."days_to_last_follow_up"."\t"."state"."\t"."days_to_recurrence"."\t"."diagnosis_id"."\t"."tumor_grade"."\t"."tissue_or_organ_of_origin"."\t"."days_to_birth"."\t"."progression_or_recurrence"."\t"."prior_malignancy"."\t"."site_of_resection_or_biopsy"."\t"."created_datetime"."\t"."case with demographic"."\t"."case_id"."\t"."updated_datetime"."\t"."created_datetime"."\t"."gender"."\t"."state"."\t"."submitter_id"."\t"."year_of_birth"."\t"."race"."\t"."demographic_id"."\t"."ethnicity"."\t"."year_of_death"."\t"."exposures information"."\t"."cigarettes_per_day"."\t"."weight"."\t"."updated_datetime"."\t"."alcohol_history"."\t"."alcohol_intensity"."\t"."bmi"."\t"."years_smoked"."\t"."height"."\t"."created_datetime"."\t"."state"."\t"."exposure_id"."\t"."submitter_id";
print FOUTC "$col_name\n";
foreach  (@splitresults) 
{ 
  ###diagnosis####
  if ($_=~/\"classification_of_tumor\"\:\s(.*),/){$a=$1;}else {$a="Unknown";};
  if ($_=~/\"last_known_disease_status\"\:\s(.*),/){$b=$1;}else {$b="Unknown";};
  if ($_=~/\"last_known_disease_status\"\:\s(.*),\s\n\s+\"updated_datetime\"\:\s(.*),/){$c=$2;}else {$c="Unknown";};
  if ($_=~/\"primary_diagnosis\"\:\s(.*),/){$d=$1;}else {$d="Unknown";};
  if ($_=~/\"primary_diagnosis\"\:\s(.*),\s\n\s+\"submitter_id\"\:\s(.*),/){$e=$2;}else {$e="Unknown";};
  if ($_=~/\"tumor_stage\"\:\s(.*),/){$f=$1;}else {$f="Unknown";};
  if ($_=~/\"age_at_diagnosis\"\:\s(.*),/){$g=$1;}else {$g="Unknown";};
  if ($_=~/\"vital_status\"\:\s(.*),/){$h=$1;}else {$h="Unknown";};
  if ($_=~/\"morphology\"\:\s(.*),/){$i=$1;}else {$i="Unknown";};
  if ($_=~/\"days_to_death\"\:\s(.*),/){$j=$1;}else {$j="Unknown";};
  if ($_=~/\"days_to_last_known_disease_status\"\:\s(.*),/){$k=$1;}else {$k="Unknown";};
  if ($_=~/\"days_to_last_follow_up\"\:\s(.*),/){$l=$1;}else {$l="Unknown";};
  if ($_=~/\"days_to_last_follow_up\"\:\s(.*),\s\n\s+\"state\"\:\s(.*),/){$m=$2;}else {$m="Unknown";};
  if ($_=~/\"days_to_recurrence\"\:\s(.*),/){$n=$1;}else {$n="Unknown";};
  if ($_=~/\"diagnosis_id\"\:\s(.*),/){$o=$1;}else {$o="Unknown";};
  if ($_=~/\"tumor_grade\"\:\s(.*),/){$p=$1;}else {$p="Unknown";};
  if ($_=~/\"tissue_or_organ_of_origin\"\:\s(.*),/){$q=$1;}else {$q="Unknown";};
  if ($_=~/\"days_to_birth\"\:\s(.*),/){$r=$1;}else {$r="Unknown";};
  if ($_=~/\"progression_or_recurrence\"\:\s(.*),/){$s=$1;}else {$s="Unknown";};
  if ($_=~/\"prior_malignancy\"\:\s(.*),/){$t=$1;}else {$t="Unknown";};
  if ($_=~/\"site_of_resection_or_biopsy\"\:\s(.*),/){$u=$1;}else {$u="Unknown";};
  if ($_=~/\"site_of_resection_or_biopsy\"\:\s(.*),\s\n\s+\"created_datetime\"\:\s(\w*)/){$v=$2;}else {$v="Unknown";}; ####写标题时记得写成diagnosis created_datetime
  ###case_id###demographic#####
  if ($_=~/\"case_id\"\:\s(.*),/){$cida=$1;}else {$cida="Unknown";};
  if ($_=~/\"updated_datetime\"\:\s(.*),/){$cidb=$1;}else {$cidb="Unknown";};
  if ($_=~/\"updated_datetime\"\:\s(.*),\s\n\s+\"created_datetime\"\:\s(.*),/){$cidc=$2;}else {$cidc="Unknown";};   ###写标题时记得写成demographic created_datetime
  if ($_=~/\"gender\"\:\s(.*),/){$cidd=$1;}else {$cidd="Unknown";};
  if ($_=~/\"gender\"\:\s(.*),\s\n\s+\"state\"\:\s(.*),/){$cide=$2;}else {$cide="Unknown";};
  if ($_=~/\"state\"\:\s(.*),\s\n\s+\"submitter_id\"\:\s(.*),/){$cidf=$2;}else {$cidf="Unknown";};
  if ($_=~/\"year_of_birth\"\:\s(.*),/){$cidg=$1;}else {$cidg="Unknown";};
  if ($_=~/\"race\"\:\s(.*),/){$cidh=$1;}else {$cidh="Unknown";};
  if ($_=~/\"demographic_id\"\:\s(.*),/){$cidi=$1;}else {$cidi="Unknown";};
  if ($_=~/\"ethnicity\"\:\s(.*),/){$cidj=$1;}else {$cidj="Unknown";};
  if ($_=~/\"year_of_death\"\:\s(\w*)/){$cidk=$1;}else {$cidk="Unknown";};
  ####exposures##############
  if ($_=~/\"cigarettes_per_day\"\:\s(.*),/){$exa=$1;}else {$exa="Unknown";};
  if ($_=~/\"weight\"\:\s(.*),/){$exb=$1;}else {$exb="Unknown";};
  if ($_=~/\"weight\"\:\s(.*),\s\n\s+\"updated_datetime\"\:\s(.*),/){$exc=$2;}else {$exc="Unknown";};
  if ($_=~/\"alcohol_history\"\:\s(.*),/){$exd=$1;}else {$exd="Unknown";};
  if ($_=~/\"alcohol_intensity\"\:\s(.*),/){$exe=$1;}else {$exe="Unknown";};
  if ($_=~/\"bmi\"\:\s(.*),/){$exf=$1;}else {$exf="Unknown";};
  if ($_=~/\"years_smoked\"\:\s(.*),/){$exg=$1;}else {$exg="Unknown";};
  if ($_=~/\"height\"\:\s(.*),/){$exh=$1;}else {$exh="Unknown";};
  if ($_=~/\"height\"\:\s(.*),\s\n\s+\"created_datetime\"\:\s(.*),/){$exi=$2;}else {$exi="Unknown";};
  if ($_=~/\"created_datetime\"\:\s(.*),\s\n\s+\"state\"\:\s(.*),/){$exj=$2;}else {$exj="Unknown";};
  if ($_=~/\"exposure_id\"\:\s(.*),/){$exk=$1;}else {$exk="Unknown";};
  if ($_=~/\"exposure_id\"\:\s(.*),\s\n\s+\"submitter_id\"\:\s(.*)/){$exl=$2;}else {$exl="Unknown";};
  
$yihang=$count."\t".$a."\t".$b."\t".$c."\t".$d."\t".$e."\t".$f."\t".$g."\t".$h."\t".$i."\t".$j."\t".$k."\t".$l."\t".$m."\t".$n."\t".$o."\t".$p."\t".$q."\t".$r."\t".$s."\t".$t."\t".$u."\t".$v."\t"." "."\t".$cida."\t".$cidb."\t".$cidc."\t".$cidd."\t".$cide."\t".$cidf."\t".$cidg."\t".$cidh."\t".$cidi."\t".$cidj."\t".$cidk."\t"." "."\t".$exa."\t".$exb."\t".$exc."\t".$exd."\t".$exe."\t".$exf."\t".$exg."\t".$exh."\t".$exi."\t".$exj."\t".$exk."\t".$exl;
  $count++;
  print FOUTC "$yihang\n";
}
close FILE;
close FOUTC;



