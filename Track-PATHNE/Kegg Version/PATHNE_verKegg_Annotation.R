#################################################
# Title: Sysmtemikon - PATHNE: Save Annotation Files
# Author(s): Richard Banh
# Version: 0.1
# Start Date: March 24, 2015
# Last Edited: April 7, 2015
#################################################
# Required Libraries
# library("KEGGREST")

######################################################################
# Collapse Data into Individual Genes annotated with Various Pathways
# To View Data in Tab Delimited Format in R, use
# d_view <- read.delim(filename_PwysOfGene, header=TRUE, sep = '\t')
######################################################################

filename_PwysOfGene <- "PATHNE_Annotation_PwysOfGene.tab"
filename_GenesOfPwy <- "PATHNE_Annotation_GenesOfPwy.tab"

	# Setup Array to Load Genes
	GenePwys_Matrix <- matrix(0, length(unique(Gene_NameList)))

	# Beginning Parameters
	Prev_Gene <- Gene_NameList[1]
	GenePwys <- Pwy_List_Matrix[1]
	Total_Genes <- 1

for (i in 2:length(Gene_NameList)) {
 Pres_Gene <- Gene_NameList[i] 

 # Reset the GenePwys List if the Previous Gene doesn't match the Present
 # Also write data to tab delimited file
 if (Prev_Gene != Pres_Gene) { 
  #print(Total_Genes)
  GenePwys_Matrix[Total_Genes] <- paste(GenePwys, collapse=", ")
  Total_Genes <- Total_Genes + 1
  GenePwys <- Pwy_List_Matrix[i]
  } 

 # Since the genes names are organized in the matrix, see if current
 # search matches the previous
 if (Prev_Gene == Pres_Gene) {
  GenePwys <- c(GenePwys, Pwy_List_Matrix[i])
  }

 # For the Last Gene in the List, write the data to file one last time
 if (i == length(Gene_NameList)) {
  #print(Total_Genes)
  GenePwys_Matrix[Total_Genes] <- paste(GenePwys, collapse=", ")
  }

 Prev_Gene <- Pres_Gene
 }

# Rename Columns and Rows of Matrix
colnames(GenePwys_Matrix) <- c("Pathways")
rownames(GenePwys_Matrix) <- unique(Gene_NameList)

# If a gene in the LoG isn't in this matrix, append "NOPWY"
# Genes annotated like this will show a Gene-Pair Score of Zero
Matrix_LoG <- rownames(GenePwys_Matrix)
Gene_SubNameList <- NULL
GenePwys_SubMatrix <- matrix(0, length(unique(LoG_KeggGeneId))-length(unique(Gene_NameList)))
count <- 1
for (gene in unique(LoG_KeggGeneId)) {
 if (sum(gene == Matrix_LoG) > 0) {
  next } # continue on with script
 else {
  GenePwys_SubMatrix[count] <- "NOPWY"
  Gene_SubNameList <- c(Gene_SubNameList, gene)
  count <- count + 1
  }
 }

# Rename Columns and Rows of Sub Matrix
colnames(GenePwys_SubMatrix) <- c("Pathways")
rownames(GenePwys_SubMatrix) <- Gene_SubNameList

# Fuse Main and Sub Matrices to Accomodate for All Genes in LoG
GenePwys_Matrix <- rbind(GenePwys_Matrix, GenePwys_SubMatrix)

######################################################################
# Collapse Data into Individual Pathways annotated with Various Genes
# To View Data in Tab Delimited Format in R, use
# d_view <- read.delim(filename_GenesOfPwy, header=TRUE, sep = '\t')
######################################################################
	# Setup Array to Load Genes
	PwyGenes_Matrix <- matrix(0, length(unique(Pwy_NameList)))

	# Beginning Parameters
	Prev_Pwy <- Pwy_NameList[[1]]
	PwyGenes <- Gene_List_Matrix[[1]]
	Total_Pwys <- 1

for (i in 2:length(Pwy_NameList)) {
 Pres_Pwy <- Pwy_NameList[[i]]

 # Reset the GenePwy List if the Previous Gene doesn't match the Present
 # Also write data to tab delimited file
 if (Prev_Pwy != Pres_Pwy) { 
  #print (Total_Pwys)
  PwyGenes_Matrix[Total_Pwys] <- paste(PwyGenes, collapse=", ")
  Total_Pwys <- Total_Pwys + 1
  PwyGenes <- Gene_List_Matrix[i]
  } 

 # Since the genes names are organized in the matrix, see if current
 # search matches the previous
 if (Prev_Pwy == Pres_Pwy) {
  PwyGenes <- c(PwyGenes, Gene_List_Matrix[[i]])
  }

 # For the Last Gene in the List, write the data to file one last time
 if (i == length(Pwy_NameList)) {
  #print (Total_Pwys)
  #test <- c(test,Pres_Pwy)
  PwyGenes_Matrix[Total_Pwys] <- paste(PwyGenes, collapse=", ")
  }

 Prev_Pwy <- Pres_Pwy
 }

# Rename Columns and Rows of Matrix
colnames(PwyGenes_Matrix) <- c("Genes")
rownames(PwyGenes_Matrix) <- unique(Pwy_NameList)

# Write Matrices to Tab Delimited File (GenePwys, PwyGenes, respectively)
write.table(GenePwys_Matrix, file=filename_PwysOfGene, append=FALSE,
row.names=TRUE, col.names=TRUE, sep="\t")
write.table(PwyGenes_Matrix, file=filename_GenesOfPwy, append=FALSE,
row.names=TRUE, col.names=TRUE, sep="\t")
