# Load Required Libraries
library("XML")
library("RCurl")
library("compiler")
source("PATHNE_functions_v2.R")

# Open ListofGenes (LoG) file
LoG_File <- read.table("ListofGenes.txt")
LoG_BioCyc <- LoG_File[["V1"]] # Access the column V1 that contains BioCyc IDs
LoG_NCBIGI <- LoG_File[["V2"]] # Access the column V2 that contains NCBI GIs

# Make Gene-Pathway Annotation File (saved)
# Make Pathway-Enzyme Annotation File (memory)
source("PATHNE_annotation_v2.R")

# Open Annotation files for analysis
PWYenz_mat <- read.delim("PWYenz_Annotation_File.tab", header=TRUE, sep = '\t')
GenePWY.xml <- xmlRoot(xmlTreeParse("GenePWY_Annotation_File.xml"))

# Make Pathway Lists for Each Gene and Iterate Comparison
for (i in 1:xmlSize(GenePWY.xml)) {
 Gene_i <- GeneName_get(GenePWY.xml[i])
 PWYs_i <- GenePWY_get(GenePWY.xml[i])

 # Loop over every other gene only once (no repeats)
 count <- i
 while(count < xmlSize(GenePWY.xml) | count == xmlSize(GenePWY.xml)) {
  Gene_j <- GeneName_get(GenePWY.xml[count])
  if (Gene_i != Gene_j) {
   PWYs_j <- GenePWY_get(GenePWY.xml[count])
  
   # Find Similarity Score between the gene-pair
   # Find number of combinations for comparing pathway sets for Gene_i
   # to the pathway set of Gene_j
   num_score <- 0
   dem_score <- length(PWYs_i) * length(PWYs_j)
  
   # Iterate over each pathway in each Pathway set, obtain 
   # Pathway-Pair score and sum it all
   num_score <- num_score + PP_score(PWYs_i,PWYs_j)
   
   # Calculate Gene-Pair Score
   score <- num_score / dem_score   
   
   # Summarize Data
   d <- data.frame(GeneA=Gene_i, GeneB=Gene_j, Score=score)
   
   # If the 1st and 2nd Gene are being compared, open a file and append data
   if (i==1 & count==2) {
    write.table(d, file="PATHNE_SIMSCORE.tab", append=FALSE,
    row.names=FALSE, col.names=TRUE, sep="\t") }
   # Otherwise, just append data to file
   else {
    write.table(d, file="PATHNE_SIMSCORE.tab", append=TRUE,
    row.names=FALSE, col.names=FALSE, sep="\t") }
  }
  count <- count + 1
 } 
}

# To View Data in Tab Delimited Format in R, use
# d_view <- read.delim("PATHNE_SIMSCORE.tab", header=TRUE, sep = '\t')
# d_view
# To view a histogram of the scores, use
# hist(d_view[['Score']], breaks=20)
