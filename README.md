# GrapHi-C
GrapHi-C: graph-based visualization of Hi-C data

generate_adjacency_graph.pl is the script used to generate an adjacency graph from Hi-C data where: linear, cis and trans interactions are represented

------------------------------------------------------------------------------------------

Example command line for Cytoscape Visualization:

./generate_adjacency_graph.pl GSM1379427_wt_999a-corrected-matrix_hic2.tsv  1258 3 10000 1 C 999a_wt.tsv
enter the starting genomic bin number for each chromosome. Enter d when complete: 1
559
1013
d
enter the ending genomic bin number for each chromosome. Enter d when complete: 558
1012
1258
d


Example command line for Gephi Visualization:

./generate_adjacency_graph.pl GSM2446256_HiC_20min_10kb.txt 1258 3 10000 1 G 20min_edges.tsv
enter the starting genomic bin number for each chromosome. Enter d when complete: 1
559
1013
d
enter the ending genomic bin number for each chromosome. Enter d when complete: 558
1012
1258
d

------------------------------------------------------------------------------------------

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
