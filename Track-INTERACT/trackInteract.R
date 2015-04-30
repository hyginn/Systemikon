# trackInteract.R
#
# Purpose: Compile gene-pair interaction data
# Version: 0.2
# Date:    2015-04-29
# Author:  Boris Steipe, based in part on contributions by Marinie Joseph
# 
# Input:   entrez gene IDs from a List-of-Genes (LoG) file
# Output:  a Gene-to-Gene (G2G) file
# Dependencies: - Uses API at http://biodbnet.abcc.ncifcrf.gov
#                 see: http://biodbnet.abcc.ncifcrf.gov/webServices/RestWebService.php
#               - CRAN package jsonlite
#               - CRAN package curl
#
# ToDo:  Define and write proper metadata
# Notes: Supported species are the model organisms of coxpresdb.jp
# ==========================================================


setwd(paste(SYSTEMIKONDIR, "/Track-INTERACT", sep=""))


# ====  PARAMETERS  ========================================

# TODO:  The species needs to be determined from the input file
# I'll just hard-code human here for now
taxID <- "9606"
taxo  <- "taxid:9606(Homo sapiens)"




# ====  PACKAGES  =========================================



# NOTE:  the iRefR package has three dependencies: igraph,
# graph, and RBGL. The igraph dependency is resolved
# by CRAN, but graph and RBGML come from BioConductor.

if (! require(graph, quietly=TRUE)) {
	source("http://bioconductor.org/biocLite.R")
	biocLite("graph")
}

if (! require(RBGL, quietly=TRUE)) {
	source("http://bioconductor.org/biocLite.R")
	biocLite("RBGL")
}
  
if (! require(iRefR, quietly=TRUE)) {
	install.packages("iRefR")
	library(iRefR)
}



# ====  FUNCTIONS  =========================================

# Define functions or source external files
# source("~/My/Script/Directory/RDefaults.R")




# ====  ANALYSIS  ==========================================



# Get the (very large, > 750MB) iref Index file by ftp if it
# doesn't yet exist locally. 
iRefRaw <- get_irefindex(taxID, "current", getwd())


# First, I would have to select only human-human interactions from
human_human_list <- data.frame(irefindex_curr_human$taxa, irefindex_curr_human$taxb)

tmp <- do.call(` paste` , c(unname(human_human_list), list(sep=".")))
irefindex_curr_human <- irefindex_curr_human[tmp == "taxid:9606(Homo sapiens).taxid:9606(Homo sapiens)"]

# While developing, it's useful to truncate this to manageable size
iRefRaw <- iRefRaw[1:100,]



# We select a subset of records for which both taxIDs are human.
# We also restrict ourselves to the columns we actually need.
iRefHS <- iRefRaw[(iRefRaw[,"taxa"] == taxo &
                         iRefRaw[,"taxb"] == taxo), ]

# we need to convert the factors into strings

iRefHS <- data.frame(lapply(iRefHS, as.character), stringsAsFactors=FALSE)




# Then I have to select the database

binary_INTACT <- select_database("intact", iRef_binary, "this_database")
binary_non_INTACT = select_database("intact", iRef_binary, "except_this_database")
complex_INTACT_CORUM = select_database(c("intact", "CORUM"), iRef_complex, "this_database")
complex_non_INTACT_CORUM = select_database(c("intact", "CORUM"), iRef_complex, "except_this_database")

# Then, I would need to convert the geneIDs to iROGs so they can be used to query the iRef database
# Before you can use convert_protein_ID() you must first
#        build the conversion table. See the help file for the function...
?create_id_conversion_table

idConvTable <- ...

#        You should use the argument: IDs_to_include = c("entrezgene/locuslink")
#        This table too should only be created if it does not already exist.

# geneid_list = c("list of genes")
# ... this is just a placeholder. You need to implement this.
#       I've just pasted a few IDs here...

x <- c("9564", "717", "973", "3078", "2534", "8517",
       "3848", "7462", "10892", "4153", "150372",
       "5788", "84174", "7070", "7189", "50852", "7334")
IDs <- cbind(x, rep("", length(x)))
colnames(IDs) <- c("geneID", "icROG")
# This matrix has a row for every geneID and 
# stores gene IDs in the first column, icROG ids
# in the second column

for (i in 1:length(geneIDs)) {
	IDs[i,"icROG"] <- convert_protein_ID("entrezgene/locuslink",
	                                     IDs[i,"geneID"],
                                         "icrogid",
                                         idConvTable)
}

# Next: remove rows that don't have an associated icROGs
IDs <- IDs[IDs[,"icROG"] != "", ]



     # icrog_list = list()
     # for (i in geneid_list) {
         # icrog_list[[i]] = convert_protein_ID("geneid", i, "icrog", id_conversion_table_human)


# Then, I would have to select multiple proteins at the same time (i.e. the converted list of genes)
table_single = select_protein("icrogid", icrog_list, irefindex_80_human, "not_full_complex")

# We'll extract the lpr (confidence) value, replace the confidence
#       string, and convert the whole column to numeric. Then we can subset ...

#       We need regular expressions ...
if (! require(stringr)) {
	install.packages("stringr")
	library(stringr)
}

# This function does the conversion...
conf2val <- function(conf, type="lpr") {
	exp <- paste(type, ":(\\d+)\\|", sep="")  # regular expression:
	                                          # capture the digits
	                                          # between :  and |
	                                          # following the type
	val <- str_match(conf, exp)[1,2]  # retrieve element 2: the captured match
    return(val)	
}

# apply the function to the "confidence" column ...
for (i in 1:nrow(iRefHS)) {
	iRefHS[i,"confidence"] <- conf2val(iRefHS[i,"confidence"])
}

# ... and convert the column to numeric
iRefHS[, "confidence"] <- as.numeric(iRefHS[, "confidence"])

# NOTE:  back to our subsetting.
#        We want all records for which either geneA or geneB
#        cROG ids are in the IDs list, and where the confidence values
#        are > 2 ...

iRefHS <- iRefHS[ (iRefHS[,"crogida"] %in% IDs[,"icROG"] |
                   iRefHS[,"crogidb"] %in% IDs[,"icROG"]) &
                  iRefHS[,"confidence"] > 2 , ]

# Finally, I need to output the MITAB table into something useful for
# downstream processing. The edgeList format offers a list of edges and their weights,
# coming from binary interactions
all_INTACT = select_database("intact", irefindex_curr_human, "this_database")
binary_INTACT = select_interaction_type("binary", all_INTACT)
complex_INTACT = select_interaction_type("complex", all_INTACT)
edgeList_all_INTACT = convert_MITAB_to_edgeList(all_INTACT, "default", "spoke")

# TO DO:  we need to update a G2G list. We now have a subset of MITAB records
#        that satisfy our selection conditions. Here's what we need to do:

# for each MITAB record
#    from its "crogida" find the geneA id in the IDs matrix  (since it's unique)
#    from its "crogidb" find the geneB id in the IDs matrix  (since it's unique)
#    check that geneA is numerically smaller than geneB ...
#        if they are equal, skip the record
#        if the ID is larger, swap them
#    write geneA, geneB, value (tab separated) to output.

# Normalize confidence values so they fall between 0 and 1
    # for a vector of numeric data, x,  a normalized vector is y <- (x - min(x)) / (max(x) - min(x))

# Write the metadata for the analysis to the output
    # write the metadata to the G2G output
    # <string:track>
    # <string:version>
    # "Gene 1","Gene 2","Score"
    # <string:gene>        <string:gene>        <float:value>





# [END]

