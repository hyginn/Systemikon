###Gene Ontology Semantic Similarity###
#R script by: Wilfred de Vega
#Version 2.0 - March 17, 2015

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