# Gene Ontology Semnatic Similarity.R
# Calculate pairwise Gene Ontology semantic similarity score based on Schlicker's method
# V 0.3
# Wilfred de Vega, April 1, 2015
#
# Semantic similarity scores, based on Schlicker's method, are calculated based on
# Cellular Component and Biological Pathway Gene Ontology terms. This track requires
# a list of genes and determine pairwise scores. The average of the two scores will be
# calculated and gene pairs with a score higher than 0.2 will be in the final output.
#
# Input:      List of Genes
# Output:     Average pairwise semantic similarity scores higher than 0.2
# Parameters: Entrez IDs are required for the genes and a Gene Ontology must exist for
# the species of interest.
#
# Notes:
#
#
# Issues / ToDo:
# Determine a more efficient way to calculate scores (currently, this track will process
# a list of 100 genes in 6 minutes with 8GB RAM).
#
# =====================

LoGtable <- read.table("listofgenes.txt", sep = "\t", header = TRUE) #this will come from List of Genes

# Load the GOSemSim library, or download it if not available.
# Will also download the 27.5 Mb dependency "GO.db" if not available
if (! require(GOSemSim)) {
	source("http://bioconductor.org/biocLite.R")
	biocLite("GOSemSim")
}

genecombo <- t(combn(LoGtable[,"Entrez.ID"], m = 2)) #obtain every possible combination of 2 genes (Entrez ID only). Transpose the matrix to make it easier to read.
colnames(genecombo)[1:2] <- c("GeneA", "GeneB") #Rename the first two columns for clarity

CCscore <- apply(genecombo, 1, function(x){ #Calculate CC GO Semantic Similarity Scores over each row (1) of the matrix
  CCSemSim <- geneSim(x[1], x[2], ont = "CC", organism = "human", measure = "Rel", combine = "BMA") #should return a vector of 3 elements
  if(length(CCSemSim) < 3){ #if a vector of a length < 3 is returned (ie. calculation fails due to lack of GO annotations)
    CC <- 0 #assign a CC score of 0
  }
  else{
    CC <- CCSemSim$geneSim #The data is organized as a vector with 3 elements so we must extract the scores this way
  }
  if(is.na(CC)){
    CC <- 0 #If the score is NA, assign a score of 0
  }
  else{
    CC <- CC
  }})

BPscore <- apply(genecombo, 1, function(x){ #Calculate BP GO Semantic Similarity Scores over each row (1) of the matrix
  BPSemSim <- geneSim(x[1], x[2], ont = "BP", organism = "human", measure = "Rel", combine = "BMA")
  if(length(BPSemSim) < 3){ #if a vector of a length < 3 is returned (ie. calculation fails due to lack of GO annotations)
    BP <- 0 #assign a BP score of 0
  }
  else{
    BP <- BPSemSim$geneSim
  }
  if(is.na(BP)){
    BP <- 0 #if BP score is NA, assign a BP score of 0
  }
  else{
    BP <- BP
  }})

RawScores <- cbind(CCscore, BPscore) #combine raw scores into table
GOSEMScore <- rowMeans(RawScores) #calculate average of raw GO Semantic Similarity Score
TOTALGOSEM <- cbind(genecombo, GOSEMScore) #compile table with all gene pairs and GOSEMScores
passthresh <- which(TOTALGOSEM[,"GOSEMScore"] > 0.2) #determines indices of the table (gene pairs) that pass the 0.2 threshold
GOSemSim <- TOTALGOSEM[passthresh,] #produce a table with gene pairs that pass GO Semantic Similarity threshold