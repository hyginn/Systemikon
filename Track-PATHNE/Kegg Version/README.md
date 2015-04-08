# Systemikon/PATHNE
This folder contains code for the pathway neighbor gene-pair annotation track.

# ListofGenes
A sample list of genes (LoG) with Kegg Gene IDs. Will need to modify scripts to accomodate for the change in filename and column in the future once the final LoG is made. 

# PATHNE
Main script for calculating simialrity scores based on KEGG IDs

# PATHNE_annotation
Pre-processing. Retrieves data from the Kegg REST API such as Pathway and Gene annotations. This information is then stored in files before two genes are compared. This step prevents downloading information from the server through multiple iterations. (In my(Richard's) opinion, it increases the speed.) Outputs Gene-Pathway annotation and Pathway-Enzyme annotation files.

# PATHNE_functions
Contains functions for retrieving annotated gene or pathway information from the files created above. Functions are compiled.

