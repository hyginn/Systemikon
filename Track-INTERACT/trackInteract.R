# trackInteract.R
# Compile gene-pair interaction data
# V 0.1
# M. Joseph & B. Steipe, March 2015
#
# This code reads a List-of-Genes file and compiles
# interaction information from the iRef database.
#
# Input:      a List-of-Genes (LoG) File
# Output:     a Gene-to-Gene (G2G) file
# Parameters: TBD
#
# Notes:
#
# Issues:
#
# =======
# History:
#
#
#
# =====================

# NOTE:  


# NOTE:  I start all my scripts with a setwd().
setwd( "... wherever")
setwd("~/Documents/00.3.REFERENCE_AND_SUPPORT/Systemikon/git/Systemikon/Track-INTERACT")

# NOTE:  You need to install the iRefR package / load the library first. There are
# three dependencies: igraph, graph, and RBGL. The igraph dependency is resolved
# by CRAN, but graph and RBGML come from BioConductor. Thus these two have to be
# loaded first for the instalation to succeeed.
if (! require(graph)) {
	source("http://bioconductor.org/biocLite.R")
	biocLite("graph")
}

if (! require(RBGL)) {
	source("http://bioconductor.org/biocLite.R")
	biocLite("RBGL")
}
  
if (! require(iRefR)) {
	install.packages("iRefR")
	library(iRefR)
}

# NOTE:  You need some mechanism to determine the species you are working
# with; I'll just hard-code human here for now
taxID <- "9606"
taxo  <- "taxid:9606(Homo sapiens)"

# Get the (very large) iref Index file by ftp if it
# doesn't yet exist locally. 
iRefRaw <- get_irefindex(taxID, "current", getwd())


# First, I would have to select only human-human interactions from the iRef database
# NOTE:  No - you can filter all of this in one go. Actually your command just
#        copies two columns from the dataframe into a new dataframe
#human_human_list <- data.frame(irefindex_curr_human$taxa, irefindex_curr_human$taxb)

# NOTE:  use the R assignment operator '<-', not '='

# NOTE:  No do.call() required here
# tmp <- do.call(` paste` , c(unname(human_human_list), list(sep=".")))
#irefindex_curr_human <- irefindex_curr_human[tmp == "taxid:9606(Homo sapiens).taxid:9606(Homo sapiens)"]

# While developing, it's useful to truncate this to manageable size
iRefRaw <- iRefRaw[1:100,]



# We select a subset of records for which both taxIDs are human.
# We also restrict ourselves to the columns we actually need.
iRefHS <- iRefRaw[(iRefRaw[,"taxa"] == taxo &
                         iRefRaw[,"taxb"] == taxo), ]


# And one more thing: the iRefR code is very poorly written - 
# we need to convert the factors into strings, they will cause
# trouble later.

iRefHS <- data.frame(lapply(iRefHS, as.character), stringsAsFactors=FALSE)




# Then I have to select the database
# NOTE: Why? I thought we just take all of them?
# binary_INTACT <- select_database("intact", iRef_binary, "this_database")
# binary_non_INTACT = select_database("intact", iRef_binary, "except_this_database")
# complex_INTACT_CORUM = select_database(c("intact", "CORUM"), iRef_complex, "this_database")
# complex_non_INTACT_CORUM = select_database(c("intact", "CORUM"), iRef_complex, "except_this_database")

# Then, I would need to convert the geneIDs to iROGs so they can be used to query the iRef database
# NOTE:  before you can use convert_protein_ID() you must first
#        build the conversion table. See the help file for the function...
?create_id_conversion_table

idConvTable <- ...

#        You should use the argument: IDs_to_include = c("entrezgene/locuslink")
#        This table too should only be created if it does not already exist.

# NOTE: should you not be using icROGs ?

# geneid_list = c("list of genes")
# NOTE: ... this is just a placeholder. You need to implement this. 
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

# TODO: are there rows with icROG IDs that are not unique?
# We should make a note of these... they need to be handled
# differently at the end...


     # irog_list = list()
     # for (i in geneid_list) {
         # irog_list[[i]] = convert_protein_ID(“geneid”, i, “irog”,
         # NOTE above: here too your word processor has inserted "smart" quotes.
         #             ... can you see the difference?
 # id_conversion_table_human)


# Then, I would have to select multiple proteins at the same time (i.e. the converted list of genes)
# table_single = select_protein("irogid", irog_list, irefindex_80_human, "not_full_complex")

# NOTE: I would again use subsetting here, and you will notice
#       that all the subsetting could actually be combined into one statement ...
#       but we'll take it step by step for now.


# Then, I have to select the confidence 
# high_confidence_complexes = select_confidence("lpr", c(1, 3:10), iRef_complex)
# ??? c(1, 3:10) doesn't make sense here - or does it?

# NOTE: unfortunately, the select_confidence() function is pretty useless
#       since we can't ask for eg. lpr values > 2 or such. Some of the lpr
#       values are over 20,000 and surely we don't want to test a value
#       against a sequence of tens of thousands of integers. We have to
#       roll our own. We'll extract the lpr value, replace the confidence
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
# all_INTACT = select_database("intact", irefindex_curr_human, "this_database")
# binary_INTACT = select_interaction_type("binary", all_INTACT)
# complex_INTACT = select_interaction_type("complex", all_INTACT)
# edgeList_all_INTACT = convert_MITAB_to_edgeList(all_INTACT, "default", "spoke")

# NOTE:  we need to update a G2G list. We now have a subset of MITAB records
#        that satisfy our selection conditions. Here's what we need to do:

# Normalize confidence values so they fall between 0 and 1

# Write the metadata for the analysis to the output

# for each MITAB record
#    from its "crogida" find the geneA id in the IDs matrix  (assuming its unique)
#    from its "crogidb" find the geneB id in the IDs matrix  (assuming its unique)
#    check that geneA is numerically smaller than geneB ...
#        if they are equal, skip the record
#        if the ID is larger, swap them
#    write geneA, geneB, value (tab separated) to output.



