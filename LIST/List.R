# List.R
#
# Purpose: (i)  Read list of gene identifiers and output accession
#               numbers in LoG format.
#          (ii) Read species identifier and output accession numbers
#               for all genes in LoG format.
# Version: 0.1
# Date:    2015-04-24
# Author:  Boris Steipe, based in part on code by Peter Boulos
# 
# Input:   Gene IDs or species name
# Output:  LoG formatted list of accession numbers
# Dependencies: - Uses API at http://biodbnet.abcc.ncifcrf.gov
#                 see: http://biodbnet.abcc.ncifcrf.gov/webServices/RestWebService.php
#               - CRAN package jsonlite
#               - CRAN package curl
#
# ToDo:  Define and write proper metadata
# Notes:
# ==========================================================

setwd("~/Documents/00.3.REFERENCE_AND_SUPPORT/Systemikon/git/Systemikon/LIST/")

# ====  PARAMETERS  ========================================

inFile <- "testGeneSymbols.txt"   # sample input
outFile <- "testListOut.txt"
API <- "http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.json?"


# ====  PACKAGES  =========================================

if (!require(jsonlite)) {
	install.packages("jsonlite")
	library(jsonlite)
}

if (!require(RCurl)) {
	install.packages("RCurl")
	library(RCurl)
}


# ====  FUNCTIONS  =========================================

# Define functions or source external files
# source("~/My/Script/Directory/RDefaults.R")

getTaxID <- function(dat) {
	# extract taxID information from dat
	# output is a string
	id <- "9606"  # default: homo sapiens 
	s <- dat[grep("taxID:", dat, ignore.case=TRUE), ]
	id <- regmatches(s, regexpr("\\d+", s, perl=TRUE))
	return <- id
}

stripMeta <- function(dat) {
	# remove all rows that contain metadata, identified
	# with a ":" in the row from a gene list
	# output vector of unique symbols
	return(unique(dat$symbol[-(grep(":", dat))]))
}

# ====  ANALYSIS  ==========================================


raw <- read.csv(inFile,
                stringsAsFactors=FALSE,
                header=FALSE,
                comment.char="#",
                blank.lines.skip=TRUE,
                col.names=c("symbol")
                )

taxID <- getTaxID(raw)
geneList <- stripMeta(raw)

RESTcall <- paste(API,
                  "method=dbfind",
                  "&inputValues=", paste(geneList, collapse=","),
                  "&output=geneid",
                  "&taxonId=", taxID,
                  "&format=row",
                  sep="")
                  
# Note: don't use fromJSON directly since it uses curl and gets
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

data <- paste("# metadata goes here ... ", 
              date(),
              "\n",
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


# [END]
