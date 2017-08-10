#!/usr/bin/perl                                                                                                           
  use strict;                                                                                                               
   use warnings;                                                                                                             
   # my $out;                                                                                                                  
   # open $out, ">helloconf";                                                                                                  
   # print $out  _EOC_;                                                                                                        
   # ppppppppppppppp                                                                                                           
   # _EOC_                                                                                                                     
my $thisSNP=1;
my $gidSt=2;
my $dGSt=3;
my @thisSnpData=($thisSNP,$gidSt,$dGSt);
   my @snpList=@thisSnpData;
   
   push  @snpList, \@thisSnpData;
   print @snpList;