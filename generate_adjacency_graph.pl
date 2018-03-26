#!/usr/bin/perl
## will generate an adjacency graph that can be input into 
## cytoscape to visualize a Hi-C dataset
##
## argument 1: the normalized whole-genome contact map
## argument 2: total number of verticies (number of genomic bins)
## argument 3: number of chromosomes
## argument 4: the value you would like to use to define a linear interaction frequency (experimental resolution)
## argument 5: a value to scale the interaction frequencies from the whole-genome contact map (enter 1 if you wish to not scale the values)
## argument 6: 'C' or 'G' to specify cytoscape or gephi visualization
## argument 7: the output file name
##
## Kimberly MacKay 
## last updated: March 23, 2017
## license: This work is licensed under the Creative Commons Attribution-NonCommercial-
## ShareAlike 3.0 Unported License. To view a copy of this license, visit 
## http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 
## PO Box 1866, Mountain View, CA 94042, USA.

use strict;
use warnings;

## check to ensure seven arguments were passed in
die "ERROR: must pass in seven arguments." if @ARGV != 7;

my $hic_file = $ARGV[0];
my $num_nodes = $ARGV[1];
my $num_chr = $ARGV[2];

## define the value of a linear frequency
my $linear_freq = $ARGV[3];

## value to scale the interaction frequencies by
my $scale = $ARGV[4];

## determine the visualization tool to be used
my $viz_tool = $ARGV[5];

## get the output file name
my $out_file_name =  $ARGV[6];

## get the values for the start and end of each chromsome from the user
my @chr_start;
my @chr_stop;

print "enter the starting genomic bin number for each chromosome. Enter d when complete: ";

my $input = <STDIN>;
chomp $input;

while(!($input =~ /d/))
{
	# add the input to the array
	push @chr_start, $input;
	
	# get the next input
	$input = <STDIN>;
	chomp $input;
}

print "enter the ending genomic bin number for each chromosome. Enter d when complete: ";

$input = <STDIN>;
chomp $input;

while(!($input =~ /d/))
{
	# add the input to the array
	push @chr_stop, $input;
	
	# get the next input
	$input = <STDIN>;
	chomp $input;
}

## gut check: ensure the size of the arrays is the same
die "ERROR: the number of chromsome start and end positions should be equal." if $#chr_start != $#chr_stop;

#########################################################################################
## print out the linear interactions
#########################################################################################

## open the output file to print
open(my $out, '>', $out_file_name) or die "Could not open $out_file_name";

## print the first line of the output file
## if it is for a cytoscape visualization, print out a different header line then the header required for Gephi visualization
if($viz_tool eq "C")
{
	print $out "source_node\tsink_node\tinteraction_type\tassociated_freq\tsource_chr\tsink_chr\tlinear_edge_chr\n";
}
elsif($viz_tool eq "G")
{
	print $out "Source\tTarget\tinteraction_type\tWeight\n";
}

## for each chromosome
for(my $chr = 1; $chr <= $num_chr; $chr++)
{
	for(my $j = $chr_start[$chr-1]; $j < $chr_stop[$chr-1]; $j++)
	{	
		## if it is a cytoscape visualization, print out the inverse of the linear frequency and relevant information
		if($viz_tool eq "C")
		{
			print $out "bin".$j."\tbin".($j+1)."\tlinear\t".1/$linear_freq."\t".$chr."\t".$chr."\t".$chr."\n";
		}
		## if it is a gephi visualization, just print out the linear frequency (it will be inversed by the force atlas 2 layout) and relavent information
		elsif($viz_tool eq "G")
		{
			print $out $j."\t".($j+1)."\tlinear".$chr."\t".$linear_freq."\n";	
		}
	}

}

close $out;

#########################################################################################
## print out the non-linear interactions
#########################################################################################

## open the interaction matrix file
open WGCM, "$hic_file" or die "ERROR: $hic_file could not be opened.";
chomp(my @hic_matrix = <WGCM>);
close WGCM;

## convert the decimals to integers and store them in a new array
## note: the 0th row and column of freq will be empty allow for a more natural
## parsing later on 
my @frequencies;

## for each line after the header line
for(my $row = 1; $row <= $#hic_matrix; $row++)
{
	## split the line
	my @matrix_line = split /\t/, $hic_matrix[$row];
	
	## loop through the entire file to extract the frequencies
	for(my $col = 1; $col <= $num_nodes; $col++)
	{
		## adjusts NA's to 0's
		if($matrix_line[$col] =~ "NA")
		{
			$frequencies[$row][$col] = 0;
		}
		else
		{
			## just store the (potentially scaled) interaction frequency
			$frequencies[$row][$col] = $matrix_line[$col]*$scale;
		}
	}
}

## re-open the output file to append to it
open($out, '>>', $out_file_name) or die "Could not open $out_file_name";


## loop through one half of the matrix and print out the edges
## avoid the diagonal to prevent self-self interactions
for(my $row = 1; $row <= $#frequencies; $row++)
{
	for(my $col = $row+1; $col <= $#frequencies; $col++)
	{
		## if it is a non-zero frequency
		if($frequencies[$row][$col] != 0)
		{
			## get the source and sink chr numbers
			my $source_chr;
			my $uknown = 1;
			
			for(my $j = 0; $j <= $#chr_stop && $uknown; $j++)
			{
				if($row <= $chr_stop[$j])
				{
					$source_chr = $j+1;
					$uknown = 0;
				}
			}
			
			my $sink_chr;
			$uknown = 1;
			
			for(my $j = 0; $j <= $#chr_stop && $uknown; $j++)
			{
				if($col <= $chr_stop[$j])
				{
					$sink_chr = $j+1;
					$uknown = 0;
				}
			}
			
			## check if it is a intra or inter interaction
			if($source_chr == $sink_chr)
			{
				## print the intra-interaction
				## if it is a cytoscape visualization
				if($viz_tool eq "C")
				{	
					print $out "bin".$row."\tbin".$col."\tintra-interaction\t".$frequencies[$row][$col]."\t".$source_chr."\t".$sink_chr."\t0\n";
				}
				## if it is a gephi visualization
				elsif($viz_tool eq "G")
				{
					print $out $row."\t".$col."\tintra-interaction\t".$frequencies[$row][$col]."\n";
				}
			}
			else
			{
				## print the inter-interaction
				## if it is a cytoscape visualization
				if($viz_tool eq "C")
				{
					print $out "bin".$row."\tbin".$col."\tinter-interaction\t".$frequencies[$row][$col]."\t".$source_chr."\t".$sink_chr."\t0\n";
				}
				## if it is a gephi visualization
				elsif($viz_tool eq "G")
				{
					print $out $row."\t".$col."\tinter-interaction\t".$frequencies[$row][$col]."\n";
				}	
			}
		}
	}
}
close $out;
