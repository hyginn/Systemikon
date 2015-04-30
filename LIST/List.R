# List.R
#
# Purpose: (i)  Read list of gene identifiers and output accession
#               numbers in LoG format.
#          (ii) Read tax-ID and output accession numbers
#               for all genes of genome in LoG format.
# Version: 0.2
# Date:    2015-04-24
# Author:  Boris Steipe, based in part on code by Peter Boulos
# 
# Input:   Gene Symbols or taxID, one element per line.
#          Comments allowed, prepend with #, optional
#          taxID must be formatted as  taxID: 12345, mandatory
#          Gene Symbols are read as strings, optional
# Output:  LoG formatted list of accession numbers
# Dependencies: - Uses API at http://biodbnet.abcc.ncifcrf.gov
#                 see: http://biodbnet.abcc.ncifcrf.gov/webServices/RestWebService.php
#               - CRAN package jsonlite
#               - CRAN package curl
#
# ToDo:  Define and write proper metadata
#        Figure out best way to get whole genome lists
#        Add all unit tests
# Notes: 
# ==========================================================

setwd(paste(SYSTEMIKONDIR, "/LIST", sep=""))

# ====  PARAMETERS  ========================================

inFile <- "testGeneSymbols.txt"   # sample input
outFile <- "testListOut.txt"
API <- "http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.json?"


# ====  PACKAGES  =========================================

if (!require(jsonlite, quietly=TRUE)) {
	install.packages("jsonlite")
	library(jsonlite)
}

if (!require(RCurl, quietly=TRUE)) {
	install.packages("RCurl")
	library(RCurl)
}

if (!require(RUnit, quietly=TRUE)) {
	install.packages("RUnit")
	library(RUnit)
}

# ====  FUNCTIONS  =========================================

# Define functions or source external files

source(paste(SYSTEMIKONDIR, "/tools/utilityFunctions.R", sep=""))
# contains getMetaData()
# contains stripMetaData()

getTaxID <- function(dat) {
	# Extract mandatory taxID information from dat
	# Output is a string
	s <- getMetaData("taxID:\\s*(\\d+)", dat) 
	if (s == "") {
		stop("No taxID record found in input.")
	}
	return(s)
}

getGenomeGenes <- function(taxID) {
	# get all genes in the taxID genome
	# TODO - best gene source is yet to be defined 

	# dummy:
	return(c("KLF4", "ZFP36", "FOS", 
	         "FOSB", "DUSP1", "ARL4A", "S100A10", 
             "JUNB", "PPP1R15A", "KLF6", "JUN"))
}


# ====  ANALYSIS  ==========================================

raw <- readLines(inFile)

taxID <- getTaxID(raw)
geneSetLabel <- getMetaData("geneSetLabel:\\s*(\\S+)", raw)
geneSetDescription <- getMetaData("geneSetDescription:\\s*([^#]+)", raw)

geneList <- stripMetaData(raw)
rm(raw)  # clean up

if (length(geneList) == 0) {
    geneList <- getGenomeGenes(taxID)
}

RESTcall <- paste(API,
                  "method=dbfind",
                  "&inputValues=", paste(geneList, collapse=","),
                  "&output=geneid",
                  "&taxonId=", taxID,
                  "&format=row",
                  sep="")
                  
# Note: don't use fromJSON() directly since it uses curl() and this gets
# a 403(forbidden) error on the host. getURL() from the RCurl package
# works.
geneidList <- fromJSON(getURL(RESTcall))

RESTcall <- paste(API,
                  "method=db2db",
                  "&format=row&input=genesymbol",
                  "&inputValues=", paste(geneidList$"Gene ID", collapse=","),
                  "&outputs=kegggeneid,genesymbol",
                  "&taxonId=", taxID,
                  "&format=row",
                  sep="")

outList <- fromJSON(getURL(RESTcall))

outList <- sapply(outList, FUN = function(x) sub("-", NA, x))

data <- paste("# LoG ", 
              date(),
              "\n",
              "geneSetLabel: ", geneSetLabel, "\n",
              "geneSetDescription: ", geneSetDescription, "\n",
              "taxID: ", taxID, "\n",
              "Entrez\tKEGG\n",
              sep = "")
data <- paste(data,
              paste(apply(outList[ , c("Gene Symbol", "KEGG Gene ID")],
                          1, paste, collapse="\t"),
                    collapse = "\n"),
              "\n",
              sep="",
              collapse="\n")


write(data, file = outFile)


# ====  TESTS  =============================================

test_getTaxID <- function() {
	checkEquals(getTaxID(c("taxID: 9606", "KLF4")), "9606")
	checkException(getTaxID(c("ZFP36", "KLF4")), silent=TRUE)
	checkException(getTaxID(c("taxID: 9606", "taxID: 9606")), silent=TRUE)
}


# [END]
