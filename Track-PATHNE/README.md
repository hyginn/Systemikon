# Systemikon/PATHNE
This folder contains code for the pathway neighbor gene-pair annotation track.

# ListofGenes.txt
A sample list of genes (LoG) with BioCyc IDs. Will need to modify scripts to accomodate for the change in filename and column in the future once the final LoG is made. 

# PATHNE_v2.R
Main script for calculating simialrity scores based on BIOCYC IDs

# PATHNE_annotation_v2.R
Pre-processing. Retrieves data from the BioCyc Web-API such as Pathway and Enzyme annotations. This information is then stored in files before two genes are compared. This step prevents downloading information from the server through multiple iterations. (In my(Richard's) opinion, it increases the speed.) Outputs Gene-Pathway annotation and Pathway-Enzyme annotation files.

# PATHNE_functions_v2.R
Contains functions for retrieving annotated gene or pathway information from the files created above. Functions are compiled.

