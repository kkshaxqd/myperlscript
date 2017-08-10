#!/usr/bin/env perl

# Program: DynamicTrim v.2.2
# Trims each sequence of a FASTQ file to the longest contiguous segment 
# for which the quality score of each base is greater than an input quality cutoff
# Murray Cox, Patrick Biggs, Daniel Peterson and Mauro Truglio
# Massey University, New Zealand
# Email contact <m.p.cox@massey.ac.nz>
# April 2013

# Version 2.0: Complete rewrite of the DynamicTrim code

# Version 2.1: Increment count to keep in concert with other programs in the package

# Version 2.2: Minor bug fix to allow 'empty' sequences in BWA algorithm

# Released under GNU General Public License version 3

use strict;
use warnings;
use Getopt::Long;
use File::Spec;

my $usage = "
$0 input_files [-p|probcutoff 0.05] [-h|phredcutoff 13] [-b|bwa] [-d|directory path] [-sanger -solexa -illumina] [-454]\n
-p|probcutoff	probability value (between 0 and 1) at which base-calling error is considered too high (default; p = 0.05) *or*
-h|phredcutoff  Phred score (between 0 and 40) at which base-calling error is considered too high
-b|bwa          use BWA trimming algorithm
-d|directory    path to directory where output files are saved
-sanger         Sanger format (bypasses automatic format detection)
-solexa         Solexa format (bypasses automatic format detection)
-illumina       Illumina format (bypasses automatic format detection)
-454            set flag if trimming Roche 454 data (experimental feature)
\n";

# if not input files provided, quit and print usage information
if( !$ARGV[0] ){ die "$usage"; }

# create cutoff variables
my $prob_cutoff;
my $phrd_cutoff;
my $ascii_cutoff;

my $automatic_detection_lines = 10000;
my $sanger;
my $solexa;
my $illumina;
my $format;
my $user_defined;

my $bwa;

my $directory;

my $roche;

my $poor_quality_char = "B";

# Get user input
GetOptions(
	"p|probcutoff=f"  => \$prob_cutoff,
	"h|phredcutoff=f" => \$phrd_cutoff,
	"b|bwa"           => \$bwa,
	"d|directory=s"   => \$directory,
	"sanger"          => \$sanger,
	"solexa"          => \$solexa,
	"illumina"        => \$illumina,
	"454"             => \$roche
);

# get user format (if supplied)
if( ($sanger && $solexa) || ($sanger && $illumina) || ($solexa && $illumina) ){
	die "error: please select only one of -sanger, -solexa or -illumina\n";
}

if( $sanger || $solexa || $illumina ){
	$user_defined = 1;
}

if( $sanger ){
	$format = "sanger";
}elsif( $solexa ){
	$format = "solexa";
}elsif( $illumina ){
	$format = "illumina";
}

if( $roche ){
	$format = "sanger";
}

# get files
my @files = @ARGV;

# check for presence of at least one input file
if( !$files[0] ){ die "$usage"; }

# check for correct cutoff input
if( !defined( $prob_cutoff ) && !defined( $phrd_cutoff ) ){
	$prob_cutoff = 0.05;
	print STDOUT "Info: Using default quality cutoff of P = $prob_cutoff (change with -p or -h flag)\n";

}elsif( defined( $prob_cutoff ) && defined( $phrd_cutoff ) ){
	die "Error: Please enter either a probability or a Phred quality cutoff value, not both";

}elsif( defined( $prob_cutoff ) && ( $prob_cutoff < 0 || $prob_cutoff > 1 ) ){
	die "Error: P quality cutoff must be between 0 and 1";

}elsif( defined( $phrd_cutoff ) && $phrd_cutoff < 0 ){
	die "Error: Phred quality cutoff must be greater than or equal to 0";
}

if( !`which R 2> err.log` ){
	print STDERR "Warning: Subsidiary program R not found. Histogram will not be produced.\n";
}
`rm err.log`;

# temp
#die &print_lookup_table;

foreach my $input_file ( @files ){

	# open input file for reading
    open( INPUT, "<$input_file" ) or die "Error: Failure opening $input_file for reading: $!\n";
		
    # just get filename, not full path (as returned by @ARGV)
    my @filepath = split( /\//, $input_file );
    my $filename = $filepath[$#filepath];
	
	# determine format
	if( !$user_defined ){
		$format = "";
	}
	if( !$format ){
		
		$format = &get_format(*INPUT, $automatic_detection_lines);
		if( !$format ){
			die "Error: File format cannot be determined\n";
		}
	}
	
	my %dict_q_to_Q;
	%dict_q_to_Q=&q_to_Q();
	
	# determine poor quality character
	if( $format eq "sanger" ){
		$poor_quality_char = "!";
	}elsif( $format eq "solexa" ){
		$poor_quality_char = ";";
	}elsif( $format eq "illumina" ){
		$poor_quality_char = "@";
	}
	
	
	
	# print format information
	if( $roche ){
		print STDOUT "User defined format: Roche 454, Sanger FASTQ format\n";
	}elsif( $format eq "sanger" ){
		if( $user_defined ){
			print STDOUT "User defined format: Sanger FASTQ format\n";
		}else{
			print STDOUT "Automatic format detection: Sanger FASTQ format\n";
		}
	}elsif( $format eq "solexa" ){
		if( $user_defined ){
			print STDOUT "User defined format: Solexa FASTQ format, Illumina pipeline 1.2 or less\n";
		}else{ 
			print STDOUT "Automatic format detection: Solexa FASTQ format, Illumina pipeline 1.2 or less\n";
		}
	}elsif( $format eq "illumina" ){
		if( $user_defined ){
			print STDOUT "User defined format: Illumina FASTQ format, Illumina pipeline 1.3+\n";
		}else{
			print STDOUT "Automatic format detection: Illumina FASTQ format, Illumina pipeline 1.3+\n";
		}
	}

	# convert input probability or Phred quality cutoff values to the equivalent ascii character
	if( defined( $phrd_cutoff ) ){
		$ascii_cutoff = &Q_to_q( $phrd_cutoff );
		$prob_cutoff = sprintf("%.5f", &Q_to_p( $phrd_cutoff ));
	}else{
		$ascii_cutoff = &Q_to_q( &p_to_Q( $prob_cutoff ) );
	}
	
	#print "format is ", $format, "\n";
	#print "prob cutoff is ", $prob_cutoff, "\n";
	#print "p to Q is ", &p_to_Q( $prob_cutoff ), "\n";
	#print "ascii cutoff is ", $ascii_cutoff, "\n";
	
	# determine bwa trimming threshold
	my $threshold = 0;
	if( $bwa ){
		
		if( defined( $phrd_cutoff ) ){
			$threshold = $phrd_cutoff;
		}else{
			$threshold = &p_to_Q( $prob_cutoff );
		}
	}

	# create and open output file
	my $output_file;
	if ( $directory ){
		# remove any trailing '/'
		$directory =~ s/\/\z//;
		my $file_name = $filename . ".trimmed";
		$output_file = File::Spec->catpath( undef, $directory, $file_name );
	}else{
		$output_file = $filename . ".trimmed";
	}
	
	if( -e $output_file ){
		die "Error: Output file $output_file already exists: $!\n";
	}    
	open( OUTPUT, ">$output_file" )
                or die "Error: Failure opening $output_file for writing: $!\n";
	
	my @segment_hist;
	my %hash=();
	my $segment_sum   = 0;
	my $segment_count = 0;
	my $original_length;
	my $seq_count = 0;

	# step through input
	while( <INPUT> ){

		# first line of each group has the sequence ID
		my $ID1 = $_;

		# check that sequence ID has FASTQ '@' indicator
		if( substr( $ID1, 0 , 1) ne "@" ){
			die "Error: Input file not in correct FASTQ format at seq ID $ID1\n";
		}
		
		# second line of the group has the sequence itself
		chomp( my $seq_string = <INPUT> );
		
		# third line of the group has the sequence ID again
		my $ID2 = <INPUT>;
		
		# check that third line has FASTQ '+' indicator
        if( substr( $ID2, 0 , 1) ne "+" ){
        	die "Error: Input file not in correct FASTQ format at qual ID $ID2\n";
		}
		
		# fourth line of the group has the quality scores
		chomp( my $quality_string = <INPUT> );
		# store the original length of the read
		$original_length  = length $seq_string;
		
		# initialize variables used in segment analysis
		my $cutoff_hit       =  0;
		my $best_start_index =  0;
		my $best_length      =  0;
		my $current_start    =  0;
		my $bad_first        =  0;
		
		# perform trimming
		if( $bwa ){
			#print("Entering bwa\n");
			my @qual = split(//, $quality_string );
			
			# transform quality values from ASCII into Solexa format

			for( my $i = 0; $i < scalar @qual; $i++ ){
				
				$qual[$i] = $dict_q_to_Q{$qual[$i]};
			}
			
			if( !$qual[0] ){
				$bad_first = 1;
				$best_length = 0;
				
			}elsif( $qual[0] < $threshold ){
				$bad_first = 1;
				$best_length = &bwa_trim( $threshold, \@qual );
			
			}else{
				$best_length = &bwa_trim( $threshold, \@qual );
			}	
			
		}else{
			
			# loop through each position in the read
			for( my $i = 0; $i < $original_length; $i++ ){
		
				# if the quality score at this position is worse than the cutoff
				if( substr($quality_string, $i, 1) le $ascii_cutoff ){
				
					$cutoff_hit = 1;
				
					# determine length of good segment that just ended
					my $current_segment_length = $i - $current_start;
				
					# if this segment is the longest so far
					if( $current_segment_length > $best_length ){
				
						# store this segment as current best
						$best_length      = $current_segment_length;
						$best_start_index = $current_start;
					}
			
					# reset current start
					$current_start = $i + 1;
					
				}elsif( $i == $original_length - 1){
					
					# determine length of good segment that just ended
					my $current_segment_length = ($i + 1) - $current_start;
				
					# if this segment is the longest so far
					if( $current_segment_length > $best_length ){
				
						# store this segment as current best
						$best_length = $current_segment_length;
						$best_start_index = $current_start;
					}
				}
			}
		
			# if quality cutoff is never exceeded, set the marker for the end of the good segment
			# to the end of the read
			if( !$cutoff_hit ){
				$best_length = $original_length;
			}
		}
		
		if( !defined($segment_hist[ $best_length ] ) ){
			$segment_hist[ $best_length ] = 0;
		}
		
		# increment variables that store segment statistics
		$segment_hist[ $best_length ]++;
		$segment_sum += $best_length;
		$segment_count++;
		if (exists $hash{$best_length}) {
    			$hash{$best_length}+=1;		
					}

		else{
    			$hash{$best_length}=1
					}	
		# remove all bases not part of the best segment
		if( $bwa ){
			
    		if( $best_length <= 1 && $bad_first ) {
      			$seq_string = "N";
      			$quality_string = $poor_quality_char;
    		}else{
     			$seq_string = substr($seq_string, 0, $best_length);
      			$quality_string = substr($quality_string, 0, $best_length);
    		}
		}else{
    		if ($best_length <= 0) {
      			$seq_string = "N";
      			$quality_string = $poor_quality_char;
    		} else {
     			$seq_string = substr($seq_string, $best_start_index, $best_length);
      			$quality_string = substr($quality_string, $best_start_index, $best_length);
    		}
		}
		# print ID lines, trimmed sequence, and trimmed quality scores to output file
		print OUTPUT $ID1, $seq_string, "\n", $ID2, $quality_string, "\n";
		
	}

	# calculate mean segment length
	my $segment_mean = sprintf( "%.1f", $segment_sum / $segment_count );

	# set index at halfway through segment counts 
	my $halfway_index = $segment_count / 2;

	# set variables needed to find median segment length
	my $current_sum   = 0;
	my $current_index = 0;
	my $median_index1;
	my $median_index2;
	
	# while median_index1 and median_index2 are not defined
	while( !defined( $median_index1 ) || !defined( $median_index2 ) ){

		# add segment count to current sum for each segment length from array
		if( defined( $segment_hist[ $current_index ] ) ){
		
			$current_sum += $segment_hist[ $current_index ];
		}

		# if current sum of segment counts has surpassed halfway index
		if( $current_sum > $halfway_index ){
		
			# if median_index1 has not been defined, store current segment length
			if( !defined( $median_index1 ) ){
				$median_index1 = $current_index;
			}

			# if median_index2 has not been defined, store current segment length
			if( !defined( $median_index2 ) ){
				$median_index2 = $current_index;
			}
		
		# else if current sum of segment counts is exactly equal to the halfway index
		}elsif( $current_sum == $halfway_index	&& !defined( $median_index1 ) ){

			# store current segment length as median_index1
			$median_index1 = $current_index;
		}

		# loop through all possible segment lengths
		$current_index++;
	}
	
	$current_index--;

	my $segment_median;

	# if number of segments is odd, store index2 as median segment length
	if( $segment_count % 2 == 1){
		$segment_median = $median_index1;
	
	# if number of segments is even, store average of index1 and index2 as median segment length
	}else{
		$segment_median = sprintf( "%.0f", ( ( $median_index1 + $median_index2 ) / 2 ) );
	}

	# print mean and median segment length
	print STDOUT "Info: $output_file: mean segment length = $segment_mean, median segment length = $segment_median\n";

	# close input and output files
	close INPUT or die "Error: Cannot close $input_file: $!";

	close OUTPUT or die "Error: Cannot close $output_file; $!";

	#Segments file generator
	my $segments_filename;
	if ( $directory ){
		#print("Directory: $directory\n");
		#print("$directory/$filename.trimmed_segments\n");
		$segments_filename="$directory/$filename.trimmed_segments";
						}
	else{
		
		$segments_filename="$filename.trimmed_segments";
				}
	open(SEGMENTS, ">$segments_filename");
	print SEGMENTS "Read_length\tProportion_of_reads\n";
	my $i;
	for ($i=0;$i <= $original_length; $i++){
		if (exists $hash{$i}){
			my $percentage=$hash{$i}/$segment_count;
			print SEGMENTS "$i\t$percentage\n";		}
		else{	print SEGMENTS "$i\t0\n";
							}
							}
	close SEGMENTS or die "Error: Cannot close $segments_filename; $!";


	############################ R histogram ##############################################################################

	open (MYFILE, '>temp.R');
	print MYFILE "
	
	filename <- \"$segments_filename\"
	cutoff <- $prob_cutoff
	output <- \"$segments_filename.hist\"
	
	d <- read.table(filename, header=T)
	maxup=max(d[,2])
	pdf( paste(output,'.pdf', sep = ''), width = 11 )
	if (maxup>0.45){
	  # I want to plot the lower values up to 55, then a split to 95 for the
	  # last top. This should make it clear which is the highest, without
	  # drowning out the other data.
	  
	  # I want the split to be approx 5% of the scale,
	  
	  # as I am to plot the ranges 0 - 55 and 95 - 140, in total 10 decades, 
	  lower=c(0,0.4)
	  upper=c(maxup-0.05, maxup)
	  # This is 10 decades. I multiply that with 2 and add 5% and get 21 units on the outer
	  # Y axis:
	  y_outer=(lower[2]+upper[1]-upper[2])*100
	  lowspan=c(0,(2*y_outer/3)-1)
	  topspan=c(lowspan[2]+5, y_outer)
	 
	  
	  cnvrt.coords <-function(x,y=NULL){
	    # Stolen from the teachingDemos library, simplified for this use case
	    xy <- xy.coords(x,y, recycle=TRUE)
	    cusr <- par('usr')
	    cplt <- par('plt')	
	    plt <- list()
	    plt\$x <- (xy\$x-cusr[1])/(cusr[2]-cusr[1])
	    plt\$y <- (xy\$y-cusr[3])/(cusr[4]-cusr[3])
	    fig <- list()
	    fig\$x <- plt\$x*(cplt[2]-cplt[1])+cplt[1]
	    fig\$y <- plt\$y*(cplt[4]-cplt[3])+cplt[3]
	    return( list(fig=fig) )
	  }
	  
	  subplot <- function(fun, x, y=NULL){
	    # Stolen from the teachingDemos l	ibrary, simplified for this use case
	    old.par <- par(no.readonly=TRUE)
	    on.exit(par(old.par))
	    xy <- xy.coords(x,y)
	    xy <- cnvrt.coords(xy)\$fig
	    par(plt=c(xy\$x,xy\$y), new=TRUE)
	    fun
	    tmp.par <- par(no.readonly=TRUE)
	    return(invisible(tmp.par))
	  }
	  
	  ##############################################
	  #
	  #
	  # The main program starts here:
	  #
	  #
	  
	  # Setting up an outer wireframe for the plots.
	  par(mar=c(8,6,6,3) + 0.1, oma=c(0,0,0,0), mgp = c(3, 1, 0))
	  plot(c(0,1),c(0,y_outer),type='n',axes=FALSE,xlab=paste(\'Length of longest contiguous read segments with quality higher than\',cutoff),col.lab=rgb(0,0.5,0), ylab='Proportion of reads', col.lab=rgb(0,0.5,0))
	  Title=tail(strsplit(strsplit(filename, '.fastq.trimmed_segments.hist')[[1]][1],'/')[[1]],1)
	  title(paste(\'Sample: \',Title))
	  mtext(paste(\"p cutoff = \",cutoff), 3, line=1)
	  mtext(paste(\"Explanation here\"), 1, line=6)
	  # Plotting the lower range in the lower 11/21 of the plot.
	  # xpd=FALSE to clip the bars
	  tmp<-subplot(barplot(d[,2],col=\'blue\',ylim=lower,xpd=FALSE,las=0, names.arg = d[,1], las=1), x=c(0,1),y=lowspan)
	  op <- par(no.readonly=TRUE)
	  par(tmp)
	  abline(h=seq(0.0,0.4,0.1), lty=1, col=\'grey\')
	  par(op)
	  subplot(barplot(d[,2],col=\'blue\',ylim=lower,xpd=FALSE,las=0, names.arg = d[,1], las=1), x=c(0,1),y=lowspan)
	 
	  
	  # Plotting the upper range in the upper 9/21 of the plot, 1/21 left to
	  # the split. Again xpd=FALSE, names.arg is set up to avoid having
	  # the names plotted here, must be some easier way to do this but
	  # this works
	
	  tmp<-subplot(barplot(d[,2],col=\'blue\',ylim=c(round(upper[1], digits = 1),round(upper[2], digits = 1)+0.1), xpd=FALSE, las=1), x=c(0,1),y=topspan)
	  op <- par(no.readonly=TRUE)
	  par(tmp)
	  abline(h=seq(round(upper[1], digits = 1),round(upper[2], digits = 1)+0.1,0.1), lty=1, col=\'grey\')
	  par(op)
	  subplot(barplot(d[,2],col=\'blue\',ylim=c(round(upper[1], digits = 1),round(upper[2], digits = 1)+0.1), xpd=FALSE, las=1), x=c(0,1),y=topspan)
	
	  # Legend. An annoiance is that the colors comes in the opposite
	  # order than in the plot.
	  
	  #legend(0.05,26,c(\'Reads\'), cex=0.7, col=c(\'blue\'), pch=15)
	  
	  # so far so good. (Just run the upper part to see the result so far)
	  # Just want to make the ends of the axes a bit nicer.
	  # All the following plots are in units of the outer coordinate system
	  
	  lowertop=lowspan[2]+(topspan[1]-lowspan[2])/2  # Where to end the lower axis
	  breakheight=1   # Height of the break
	  upperbot=lowertop+breakheight#(lowspan[2]+(topspan[1]-lowspan[2])/2)+breakheight# Where to start the upper axes
	  markerheight=0.5 # Heightdifference for the break markers
	  markerwidth=.03  # With of the break markers
	  
	  # Draw the break markers:
	  #lines(c(0,0),c(1,lowertop))
	  lines(c(markerwidth/-2,markerwidth/2),c(lowertop-markerheight/2,lowertop+markerheight/2))
	  #lines(c(0,0),c(upperbot-breakheight,14))
	  #lines(c(0,0),c(upperbot,maxup))
	  lines(c(markerwidth/-2,markerwidth/2),c(upperbot-markerheight/2,upperbot+markerheight/2))
	
	  }else{
	
	  par(mar=c(8,6,6,3) + 0.1, oma=c(0,0,0,0), mgp = c(3, 1, 0))
	  barplot(d[,2], names.arg = d[,1], space = 0, ylim=c(0, 0.4), col=\'blue\', las=1, xlab=paste(\'Length of longest contiguous read segments with quality higher than\',cutoff),col.lab=rgb(0,0.5,0), ylab=\'Proportion of reads\', col.lab=rgb(0,0.5,0), axis.lty = 1, cex.names = 0.9 )
	  abline(h=seq(0.1,0.4,0.1), lty=1, col=\'grey\')
	  barplot(d[,2], add=TRUE, names.arg = d[,1], space = 0, ylim=c(0, 0.4), col=\'blue\', las=1, xlab=paste(\'Length of longest contiguous read segments with quality higher than\',cutoff),col.lab=rgb(0,0.5,0), ylab=\'Proportion of reads\', col.lab=rgb(0,0.5,0), axis.lty = 1, cex.names = 0.9 )
	
	  Title=tail(strsplit(strsplit(filename, '.fastq.trimmed_segments.hist')[[1]][1],'/')[[1]],1)
	  title(paste(\'Sample: \',Title))
	  mtext(paste(\"p cutoff = \",cutoff), 3, line=1)
	  mtext(\"Sum of the segments = 1\", 1, line=6)

	  #legend(0.05,0.35,c(\'Reads\'), cex=0.7, col=c(\'blue\'), pch=15)
	}
	  garbage<-dev.off()
	";
	 
	close (MYFILE);
	
	system("Rscript temp.R");
	system("rm temp.R");

}



	
# terminate
exit 0 or die "Error: program $0 ended abnormally: $!\n";

# ----------------------------------------------------

# Change ASCII character to Phred/Solexa quality score
sub q_to_Q(){

        if( $format eq "sanger" ){
		my $num;
		my %dict_q_to_Q=();
		for($num=33; $num<=126; $num++){	
			$dict_q_to_Q{chr($num)}=$num-33;}
        	return %dict_q_to_Q;
		
        }else{
		my $num;
		my %dict_q_to_Q=();
		for($num=64; $num<=126; $num++){	
			$dict_q_to_Q{chr($num)}=$num-64;}
		return %dict_q_to_Q;
}}

# Change Phred/Solexa quality score to ASCII character
sub Q_to_q($){

        my $Q = shift;
        if( $format eq "sanger" ){
        	return chr($Q + 33);
        }else{
        	return chr($Q + 64);
        }
}

# Change Phred/Solexa quality score to probability
sub Q_to_p($){

	my $Q = shift;

	if( $format eq "solexa" ){
		return (10**(-$Q/10)) / ((10**(-$Q/10))+1);
	}else{
		return (10**(-$Q/10));
	}
}

# Change probability to Phred/Solexa quality score
sub p_to_Q($){

	my $p = shift;
		
		if( $format && $format eq "solexa" ){
			return -10 * &log10($p/(1-$p));
        }else{
			return -10 * &log10($p);
        }
}

# log10 function
sub log10($){

	my $number = shift;
	return log($number)/log(10);
}

# print summary of Q, q and p values
sub print_lookup_table(){
	
	print STDOUT "Char\tQPhred\tProb\n";
	for( my $i = -5; $i <= 93; $i++ ){
		
		my $q = &Q_to_q($i);
		my $p = &Q_to_p($i);
		
		print STDOUT $q, "\t";
		print STDOUT $i, "\t";
		print STDOUT sprintf("%.8f", $p), "\n";
	}
}

# automatic format detection
sub get_format(*$){
	
	# set function variables
	local *FILEHANDLE = shift;
	my $number_of_sequences = shift;
	my $format = "";
	
	# set regular expressions
	my $sanger_regexp = qr/[!"#$%&'()*+,-.\/0123456789:]/;
	my $solexa_regexp = qr/[\;<=>\?]/;
	my $solill_regexp = qr/[JKLMNOPQRSTUVWXYZ\[\]\^\_\`abcdefgh]/;
	my $all_regexp = qr/[\@ABCDEFGHI]/;
	
	# set counters
	my $sanger_counter = 0;
	my $solexa_counter = 0;
	my $solill_counter = 0;
	
	# go to file start
	seek(FILEHANDLE, 0, 0);
	
	# step through quality scores
	for( my $i = 0; $i < $number_of_sequences; $i++ ){
		
		# test for end of file
		last if eof(FILEHANDLE);
		
		# retrieve qualities
		<FILEHANDLE>;
		<FILEHANDLE>;
		<FILEHANDLE>;
		my $qualities = <FILEHANDLE>;
		chomp($qualities);
		
		# check qualities
		if( $qualities =~ m/$sanger_regexp/ ){
			$sanger_counter = 1;
			last;
		}
		if( $qualities =~ m/$solexa_regexp/ ){
			$solexa_counter = 1;
		}
		if( $qualities =~ m/$solill_regexp/ ){
			$solill_counter = 1;
		}
	}
	
	# determine format
	if( $sanger_counter ){
		$format = "sanger";
	}elsif( !$sanger_counter && $solexa_counter ){
		$format = "solexa";
	}elsif( !$sanger_counter && !$solexa_counter && $solill_counter ){
		$format = "illumina";
	}
	
	# go to file start
	seek(FILEHANDLE, 0, 0);
	
	# return file format
	return( $format );
}

# trim sequences using the BWA algorithm
sub bwa_trim($$){
	
	my $threshold = shift;
	my $array_ref = shift;
	
	my @array  = @{$array_ref};
	my $length = scalar @array;
	
	# only calculate if quality fails near end
	if( $array[$#array] >= $threshold ){
		return $length;
	}
	
	# run bwa equation
	my @arg;
	for( my $i = 0; $i < $length - 1; $i++ ){
		
		my $x = $i + 1;
		for( my $j = $x; $j < $length; $j++ ){	
			$arg[$x] += $threshold - $array[$j];
		}
	}
	
	# find number of 5' bases to retain
	my $index = 0;
	my $maxval = 0;
	for ( 1 .. $#arg ){
		if ( $maxval < $arg[$_] ){
        	$index = $_;
        	$maxval = $arg[$_];
    	}
	}
	
	# number of bases to retain
	return $index;
}
