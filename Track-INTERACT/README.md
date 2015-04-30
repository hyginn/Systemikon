# Systemikon/INTERACT
This folder contains code (written in R) for the protein-protein interaction gene-pair annotation track, as part of a larger project aimed at elucidating biogical systems from molecular data. 
# Introduction
The interact track uses protein interaction data to annotate a list of genes with pairwise interactions, and outputs results in a gene-to-gene format.
#Libraries
This function requires the iRefR package to be downloaded. There are three dependencies: igraph, graph, and RBGL. The igraph dependency is resolved by CRAN, but graph and RBGML come from BioConductor. 


```
source ("ftp://ftp.no.embnet.org/irefindex/iRefR/current/")

source("http://bioconductor.org/biocLite.R")
	biocLite("graph")

source("http://bioconductor.org/biocLite.R")
	biocLite("RBGL")
```
# To Do
- [ ] Normalize confidence values between 0 and 1
- [ ] Write metadata to output