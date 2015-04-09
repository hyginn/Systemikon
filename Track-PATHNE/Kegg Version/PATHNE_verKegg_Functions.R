#################################################
# Title: Sysmtemikon - PATHNE: Save Annotation Files
# Author(s): Richard Banh
# Version: 0.1
# Start Date: March 24, 2015
# Last Edited: April 7, 2015
#################################################
# Required Libraries
# library("KEGGREST")

# Obtain Pathway Names from File of 'Genes Annotated with Pathways'
retrievePwyNames <- function(PwysOfGene_mat, Gene) {
 # Append Pathway Name to Vector
 namelist <- strsplit(toString(PwysOfGene_mat[Gene,"Pathways"]), ', ')[[1]]
 namelist
 }

# Obtain Gene Names from File of 'Pathways Annotated with Genes'
retrieveGeneNames <- function(PwysOfGene_mat, Pathway) {
 # Append Pathway Name to Vector
 namelist <- strsplit(toString(GenesOfPwy_mat[Pathway,"Genes"]), ', ')[[1]]
 namelist
 }

# Calculate Pathway-Pathway Score
PP_score <- function(Pwys_i,Pwys_j) {
 PwPw_score <- 0
 # Iterate over each pathway in each Pathway set
 for (a in Pwys_i) {
  for (b in Pwys_j) {
   genes_ab <- NULL
   if (a == "NOPWY" | b == "NOPWY") {
    PwPw_score <-0 }
   if (a == b) {
    if (a == "NOPWY" | b == "NOPWY") {
     PwPw_score <- 0 }
    else {PwPw_score <- PwPw_score + 1}
    }
   else {
    genes_a <- retrieveGeneNames(GenesOfPwy_mat,a)
    genes_b <- retrieveGeneNames(GenesOfPwy_mat,b)

    # Merge the two sets of enzyme data
    genes_ab <- c(genes_a, genes_b)

    # Analyze the similarities between two different pathways
    # Find number of repeated genes in the vector that
    # contains genes from both pathways (similarity #)
    # +1 to score if enz. exists in both, 0 otherwise
    # Find maximum number uniqe enzymes in each set
    int_score <- sum( duplicated(genes_ab) ) / length(unique(genes_ab))
    PwPw_score <- PwPw_score + int_score
    }
   }
  }
  PwPw_score
 }