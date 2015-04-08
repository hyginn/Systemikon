# Systemikon/PATHNE
This folder contains code for the pathway neighbor gene-pair annotation track.

## Description
Currently there are two large databases that contain pathway information about genes: KEGG and BIOCYC. The advantage of using KEGG Gene IDs is that the conversion from other IDs has a high yield. The advantage of using BIOCYC is that there are more genes are annotated to pathways than there are in KEGG. However, conversion of other IDs to BIOCYC is difficult at the moment (April 7, 2014). This project aims to integrate information from these databses to generate pathway neighbour gene-pair scores.

###Status:
####BioCyc Version (Testing, last updated March 13)
*Current Issue(s): There is a low yield of BioCyc IDs (required) from Gene ID conversions.*
####Kegg Version (Running, version 0.1)
*Current Issue(s): Have not addressed problem of multiple KEGG Gene IDs given for one Gene Symbol. Have not addressed problem of what to do if there is no KEGG Gene ID for a given Gene Symbol. Have not addressed problem of what to do if there is no Pathway annotated to a gene.

## Methodology
1. Genes are annotated with Pathways from Database(s): KEGG and/or BIOCYC
2. The set of unique pathways obtained from all genes is annotated with genes pertaining to that pathway.
3. A similarity score is calculated: For each pathway that exists in both pathway sets for each gene (input), a score of 1 is given (aka pathway-pair score). For different pathways, a pathway-pair score is calculated ranging from 0 to 1. This value is calculated by summing the number of same genes that exist in both pathways and dividing it by the number of unique genes between the two. The similarity score between gene-pairs was calculated by taking the sum of pathway-pair scores and dividing it by the number of pathway-pairs between the two genes.

# General File Descriptions
## ListofGenes
A sample/random list of genes (LoG) with BIOCYC/ KEGG Gene IDs. Will need to modify scripts to accomodate for the change in filename and column in the future once the final LoG is made. 

## PATHNE
Main script for calculating similarity scores based on BIOCYC/KEGG Gene IDs.

## PATHNE_annotation
Pre-processing. Retrieves data from the Kegg REST API such as Pathway and Gene annotations. This information is then stored in files before two genes are compared. This step prevents downloading information from the server throughout multiple iterations. Outputs *Gene-Pathways annotation* and *Pathway-Genes annotation* files.

*Note: The current testing version of the BIOCYC script utilizes the BIOCYC Web API to download and save pathway and gene annotation data.*

## PATHNE_functions
Contains functions for retrieving annotated gene or pathway information from the files created above. 

