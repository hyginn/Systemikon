# analyzeTrackData
# simple analyis of track data
# V 0.1
# B. Steipe, March 2015
#
# This code reads data in the G2G format and performs
# some simple analyses.
#
# parameters: number of gene symbols written to output
# =====================

PsetsFile <- "PearsonMar13list.dat"
PrandFile <- "PearsonMar17list.dat"
MICsetsFile <- "MICMar13list.dat"
MICrandFile <- "MICMar17list.dat"

setwd("... wherever")

read.G2G <- function(fileName) {
   df <- read.delim(fileName,
                    header = FALSE,
                    comment.char= "#",
                    blank.lines.skip = TRUE,
                    stringsAsFactors = FALSE)
   colnames(df) <- c("GeneA", "GeneB", "Val")
   return(df)	
}

Psets   <- read.G2G(PsetsFile)
Prand   <- read.G2G(PrandFile)
MICsets <- read.G2G(MICsetsFile)
MICrand <- read.G2G(MICrandFile)

summary(Psets)
summary(Prand)
summary(MICsets)
summary(MICrand)

# histograms of the data - 4 per plot
op <- par(mfrow = c(2, 2))
hist(abs(Psets$Val), n=20, col="#FFEEEE")
hist(abs(Prand$Val), n=20, col="#EEEEFF")
hist(MICsets$Val, n=20, col="#FFFFEE")
hist(MICrand$Val, n=20, col="#EEFFEE")
par(op)

# scatterplots of Pearson vs. MIC
op <- par(mfrow = c(2, 1), pty="s")
plot(abs(Psets$Val), MICsets$Val, cex=0.5, pch=16, col="#FF000033")
plot(abs(Prand$Val), MICrand$Val, cex=0.5, pch=16, col="#0000FF33")
par(op)

# qqplots of Pearson vs. MIC
op <- par(mfrow = c(1, 2))
qqplot(abs(Psets$Val), MICsets$Val, cex=0.5, pch=16, col="#FF000007")
qqplot(abs(Prand$Val), MICrand$Val, cex=0.5, pch=16, col="#0000FF12")
par(op)



# END

