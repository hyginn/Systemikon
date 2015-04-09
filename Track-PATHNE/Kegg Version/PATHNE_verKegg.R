#################################################
# Title: Sysmtemikon - Main Script for PATHNE Analysis
# Author(s): Richard Banh
# Version: 0.1
# Start Date: March 24, 2015
# Last Edited: April 7, 2015
#################################################
# Description:
# 	Gene-Pair Scores are calculated using online databases. 
# These scores represent the similarity between two genes
# based on their related pathways. Also, incorporated is
# a pathway-pair similarity score to acknowledge that some
# pathways may be similar.
#################################################
# Methodology: 
#    This code uses the Bioconductor KEGG library
# to access the Kegg database by Kegg Gene IDs. Genes are 
# annotated with a set of pathways, then pathways are annotated
# with a set of genes and a similarity score is calculated at the
# end. If two pathways exist between two genes (inputs) then it is
# given a score of one. If there are two pathways that are different
# between two genes (inputs), then the pathways are given a similarity
# score based on annotated genes to the respective pathway. The total
# nubmer of unique genes (annotated to pathways) between pathways is
# also found. The summation of the first is then divided by the latter
# to give a maximum similarity score of 1 between pathways. The same
# calculation is performed to calculate the similarity score between
# genes (inputs).
#################################################
# Future Tasks (last edited April 7, 2015):
# 1. Dealing with multiple KEGG Gene IDs. How many to use? Which to use?
# 2. Find out how the organism name might differ - fix org id code if so.
# 3. Output Gene IDs correct? Consistent with others?
# 4. Is the script need to change to match the input list of genes?
# 5. Is another round of iteration required? i.e. annotating the genes
#	from the 'pathway annotated with genes' data. Is another round of
#	annotation required after that? Does this approach some kind of
#	limit? May help with distibutions a bit in the future.
#################################################

# Time the script
# Start the clock! (End Clock is at end of script)
# ptm <- proc.time()

###################################################
# Load required libraries and download if necessary
###################################################
if (! require(KEGGREST)) {
	source("http://bioconductor.org/biocLite.R")
	biocLite("KEGGREST")
}
library("KEGGREST")


#####################
# File Names Required
#####################
## Main Script
filename_ListOfGenes<- "ListOfGenes_keggSAMPLE.txt"
filename_ListOfGeneswEntrez <- "ListOfGenes_keggSAMPLEwEntrezID.txt"
filename_SimOutput  <- "PATHNE_SIMSCORE.csv"
#
## Annotation Script (Fix inside Annotation Script)
#filename_PwysOfGene <- "PATHNE_Annotation_PwysOfGene.tab"
#filename_GenesOfPwy <- "PATHNE_Annotation_GenesOfPwy.tab"


######################################################
# Load List of Genes (LoG) into Vectors
#... Will require changing once the final list is made

	###############################	
	# Input File Format: (txt)
	###############################
	# Gene_Symbol	KEGG_GENE_ID
	# BCAR1	hsa:9564
	###############################

######################################################
LoG_File <- read.table(filename_ListOfGenes, header=TRUE)
LoG_GeneSymbol <- as.vector(LoG_File[,"Gene_Symbol"])
LoG_KeggGeneId <- as.vector(LoG_File[,"KEGG_Gene_ID"])
#LoG_EntrezId <- as.vector(LoG_File[,"Entrez_ID"]) # For Future

# Temporary ... can remove once one file for the LoG is made
LoG_File_EntrezId <- read.table(filename_ListOfGeneswEntrez, header=TRUE)
LoG_EntrezId <- as.vector(LoG_File_EntrezId[,"Entrez_ID"])

################################################
# Downloading Data: Pathway and Gene Annotations
################################################
  # Annotate Genes with Pathway Data
    # Pathway list matrix with rownames representing KeggGeneIds
    # Take all row names from the matrix 
    # (gives vector of gene names corresponding to each pathway)
    Pwy_List_Matrix <- as.matrix(keggLink("pathway", LoG_KeggGeneId))
    Gene_NameList <- rownames(Pwy_List_Matrix)

    # Obtain Kegg Three Letter Organism ID (required for Annotation)
    org = unique(strtrim(Gene_NameList,3))

    # Gene list matrix with rownames representing KeggPathwayIds
    # Take all row names from the matrix
    # (gives vector of pathway names corresponding to each gene)
    Gene_List_Matrix_temp <- as.matrix(keggLink(org, unique(Pwy_List_Matrix)))
    Pwy_NameList_temp <- rownames(Gene_List_Matrix_temp)

    # Make Data Frame with Pathway names in a Separate Column
    # Performed because multiple rownames were repeated and the Pathways 
    # weren't sorted
    PwyGenes_df <- data.frame(Gene=Gene_List_Matrix_temp, Pathway=Pwy_NameList_temp, rowname=FALSE, ordered=TRUE)
    PwyGenes_df <- PwyGenes_df[order(PwyGenes_df$Pathway),]
	
    # Obtain Pathway Ordered List and Gene Ordered List
    Gene_List_Matrix <- as.matrix(PwyGenes_df$Gene)
    Pwy_NameList <- as.matrix(PwyGenes_df$Pathway)


###########################################################
# Save Server Data to File (Used it more efficiently later)
###########################################################
#Annotate Genes with Pathways & Pathways with Genes
source("PATHNE_verKegg_Annotation.R")
	

#####################################
# Load Annotation Files into Matrices
#####################################
PwysOfGene_mat <- read.delim(filename_PwysOfGene, header=TRUE, sep = '\t')
GenesOfPwy_mat <- read.delim(filename_GenesOfPwy, header=TRUE, sep = '\t')


############################################
# Required Functions for Similarity Analysis
############################################
# F(x): Extracts string data from each annotated pathway or gene
source("PATHNE_verKegg_Functions.R")


###########################################################
# Similarity Analysis: Gene-Pair Scores

	######################################
	# Output File Format
	######################################
	# "", "Gene 1","Gene 2","PATHNEScore"
	# 1,"BCAR1","C2","0.0158425148981058"
	######################################

# Note 1: Genes annotated with "NOPWY" are given a score of 0
# This can be fixed in the functions script 

# Note 2: Genes with no Kegg Gene ID are given a score of 0
 
###########################################################
# Calculate for the number of gene-pair combinations
n <- length(LoG_KeggGeneId) # Length of LoG
r <- 2 # Choose 2 (Combination Calculation)
combin <- factorial(n) / (factorial(r) * factorial(n-r))

# Set Similarity Matrix Array
# Note: using combin alone in the matrix gives -1 of what combin is for some odd reason
Similarity_Matrix <- matrix(0, combin+1, 4) 

# Line Counter for Matrix as Data is Appended
line <- 1

# What type of ID will be appended to the output file?
#LoG_ID <- LoG_GeneSymbol
LoG_ID <- LoG_EntrezId

# Iteration to Calculate Gene-Pair Scores as well as appending data to a matrix
  # Loop over each gene from the original LoG and compare with different genes
  for (i in 1:length(LoG_KeggGeneId)) {
    Gene_i <- LoG_KeggGeneId[i]
    Gene_i_Alt <- LoG_ID[i]
    Pwys_i <- retrievePwyNames(PwysOfGene_mat, Gene_i)
	 
    # Loop over every other gene only once (no repeats)
    count <- i + 1 # Counter for genes.
    while (count < length(LoG_KeggGeneId) | count == length(LoG_KeggGeneId)) {
      Gene_j <- LoG_KeggGeneId[count] # Change to another Symbol if you wish
      Gene_j_Alt <- LoG_ID[count]

      # For Genes that don't have Kegg Gene IDs
      if (Gene_i == '-' | Gene_j == '-') { score <- 0 }
	
      # For Same Genes that both have Kegg Gene IDs
	if (Gene_i == Gene_j & (Gene_i != '-' | Gene_j != '-')) { score <- 1 }

	# For Different Genes
      if (Gene_i != Gene_j & (Gene_i != '-' | Gene_j != '-')) {
        Pwys_j <- retrievePwyNames(PwysOfGene_mat, Gene_j)
	  
        # Calculating Similarity Score between Gene-Pair
        # Find Number of Combinations for Comparing Pathway Sets Between Gene i and j
        num_score <- 0
        dem_score <- length(Pwys_i) * length(Pwys_j)

        # Iterate Over Each Pwy in each Pwy Set
        # Obtain Pathway-Pair Score and Sum it All
        num_score <- num_score + PP_score(Pwys_i, Pwys_j)

        # Calculate Gene-Pair Score
        score <- num_score / dem_score 
  	  }
      count <- count + 1

      # Write Data Frame For File
      Similarity_Matrix[line,] <- c(line, Gene_i_Alt, Gene_j_Alt, score)
      line <- line + 1
      } 
    }

# Rename columns and Save Similarity Matrix to File
colnames(Similarity_Matrix) <- c("", "Gene 1", "Gene 2", "PATHNEScore")
write.table(Similarity_Matrix, file=filename_SimOutput, append=FALSE,
row.names=FALSE, col.names=TRUE, sep=",")

# To View Data in Tab Delimited Format in R, use
# d_view <- read.delim(filename_SimOutput, header=TRUE, sep = ',')
# d_view
# To view a histogram of the scores, use
# hist(d_view[['PATHNEScore']], breaks=seq(0,1.0, by=1/30), freq=FALSE, ylab="Percentage")

# Stop the clock for timing script (Start Clock is at top of script)
# print(proc.time() - ptm)
