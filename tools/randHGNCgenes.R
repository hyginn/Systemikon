# randHGNCgenes
# choose random genes from HGNC
# V 0.1
# B. Steipe, March 2015
#
# This code picks a number of random genes from a list
# of HUGO Gene Nomenclature Committee published symbols.
# The list contains both protein genes as well as 
# non-coding RNA genes.
# Only symbols for which Entrez gene IDs are available
# are stored.
#
# parameters: number of gene symbols written to output
# =====================

nOut <- 100   # Number of symbols to pick
fileName <- "HGNC_genes.txt"

setwd("... wherever")

genes <- read.delim(fileName,
                    header = FALSE,
                    comment.char= "#",
                    blank.lines.skip = TRUE,
                    stringsAsFactors = FALSE)

set.seed(112358)
idx <- sample(1:nrow(genes), nOut, replace=FALSE)

for (i in 1:nOut) {
	cat(genes[idx[i],1], "\t", genes[idx[i],2], "\n")
}

# END

