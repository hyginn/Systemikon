# utilityFunctions.R
#
# Purpose: Various utility functions
# Version: 0.1
# Date:    2015-04-30
# Author:  All
# 
# Input / Output / Dependencies: See at function
#
# ToDo:  Add all unit tests
# Notes: 
# ==========================================================

# ====  GENERAL  ===========================================

if (!require(RUnit, quietly=TRUE)) {
	install.packages("RUnit")
	library(RUnit)
}


# ====  getMetaData()  =====================================

if (!require(stringr, quietly=TRUE)) {
	install.packages("stringr")
	library(stringr)
}

getMetaData <- function(pattern, dat) {
	# Extract meta-data from <dat> with regex search
	#   for <pattern>
	# Output the matching string, 
	#   empty string if no match 
	i <- grep(pattern, dat)
	if (length(i) == 0) {
		return("")
	} else if (length(i) > 1) {
		stop("Found more than one matching pattern in input.")
	}	
	m <- regexec(pattern, dat[i])
	s <- regmatches(dat[i], m)[[1]][2]
	return(str_trim(s))
}

# ====  stripMetaData()  ===================================

stripMetaData <- function(dat) {
    # Remove all comments
	# Remove all elements that contain metadata, identified
	#   with a ":" in the row
	# Trim all whitespace
	# Remove empty lines
	# Output vector of unique records or empty vector
	dat <- sub("#.*$", "", dat)
	dat <- str_trim(dat)
	meta <- grep(":", dat)
	empty <- which(dat == "")
	dat <- dat[-(c(meta, empty))]
	return(unique(dat))
}



# ====  TESTS  =============================================

test_getMetaData <- function() {
    # TODO
	return(TRUE)
}

test_stripMetaData <- function() {
    # TODO
	return(TRUE)
}


# [END]
