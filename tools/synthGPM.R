# synthGPM
# synthetic Gene-Pair Multigraph from first principles
# V 0.1.1
# B. Steipe, March 2015
#
# This code synthesizes random Gene-pair multigraphs from
# parameters: number of genes, number of systems and 
# number/names of annotation tracks. More adjustable
# parameters, see below.
#
# A preferential-attachment procedure creates a distribution
# of system sizes that corresponds to Zipf's law.
#
# This does not create hierarchical systems.
# 
# Added output option to write numeric gene IDs and system IDs.
# =====================

nGenes <- 100   # Number of genes
nSystems <- 5  # Number of Systems

trackNames <- c("")
trackNames[1] <- "iRef"
trackNames[2] <- "GEO"
trackNames[3] <- "GO"
trackNames[4] <- "pathW"

pWithin <- 0.8
# Probability that a gene pair within a system
# shares an edge. The minimum should be calculated
# from Erdös-Rényi theory so as to ensure that
# the graph for the system is almost certainly
# connected. The required probability for an
# edge between a pair is log(n)/n where n is the
# System size: for 20,000 genes and 1,000 systems
# the average system size is 20 and pWithin is 0.1498
# The maximum would be for each system to be fully
# connected, i.e. pWithin is 1.0 
# For 20,000 genes and 1,000 systems, if
# each sytem is fully connected, it turns out the
# average node-degree is about 10. Coincidentally(?)
# that is also approximately the average number of 
# iREF annotations per human gene.

meanDegree <- 10   # Mean node-degree in graph

pBetween <- ((1 - pWithin) * meanDegree * nGenes) / 
            (((nGenes^2)-nGenes)/2)
# Probability that a gene pair between systems
# shares an edge.
# Of the total number of edges, the pWithin portion
# has been assigned within systems, the remainder
# are between-systems edges. A total of M <- ((x^2)-x)/2
# such edges are possible where x is the number of
# genes ... this is very much larger than the number
# of within-system edges. The probability of an edge
# pair is thus ((1-pWithin) * 10 * nGenes) / M ... or
# about 0.00085


baseWeight <- 0.8  # The basic weight for all tracks
baseSpread <- 2    # The spread for an Edge-tuple weight
betweenTracksSpread <- 2
threshold <- 0.5
# Weights are determined by computing a probability for
# a tuple from baseWeight and baseSpread, then using this 
# probability as a basis, producing a random weight for each
# of the tracks according to the betweenTracksSpread.
# Weights below threshold are set to zero.


# =================================================
# Part one: Determine system sizes:
# =================================================

# We use a preferential attachment model in which
# the probability of a gene attaching to a system
# depends on the system size.
# This is done through an energy-based model:
# the probability of a gene attaching to a system
# is taken as 1/nSystems. This is converted to a
# statistical free energy. Every additional gene 
# in a system decreases the energy by
# the same amount, and thus increases the probability
# of attaching a new gene and growing the system.
# Growth is pursued until all genes have been assigned
# to a system.

# The resulting distribution is approximately
# scale-free (linear on a log(rank) vs. log(size)) plot


mapE2P <- function(DG) {
	# convert energy difference to probability
	R <- 0.0083144621 # Gas constant in kJ/(K * mol)^-1
	Temp <- 273.16 + 25.0 # 25° C
	K <- exp(DG/(-R * Temp))
	p <- K/(K+1)  # Convert ratio to probability
	return(p)
}

mapP2E <- function(P) {
	# convert probability to energy difference
	R <- 0.0083144621 # Gas constant in kJ/(K * mol)^-1
	Temp <- 273.16 + 25.0 # 25° C
	K <- 1/((1/P)-1)  # convert probability to ratio
	DG <- -R * Temp * log(K)
	return(DG)
}

EBase <- mapP2E(1 / nSystems )
EGene <- mapP2E(1 / (nSystems-1)) - EBase  
                           # The energy contributed 
                           # by a single gene in the
                           # system.
set.seed(1597)
sysSizes <- rep(1, nSystems)

while (sum(sysSizes) < nGenes) {
	i <- as.integer(runif(1,min=1, max=(nSystems+1))) # pick a random system
	p <- mapE2P(EBase + (sysSizes[i] * EGene))  # calculate probability to attract
	                                            # a gene.
	# roll the dice:
	if (runif(1) <= p) {
		sysSizes[i] <- sysSizes[i] + 1
	}
}
sysSizes <- sysSizes[order(sysSizes)]  # Order systems by size for convenience

# sum(sysSizes)
# hist(sysSizes)
# plot(log(sysSizes), -log(1:length(sysSizes)))
# summary(sysSizes)


# =================================================
# Part two: Assign edges
# =================================================

# Create a genes/systems vector
geneSys <- rep(0, nGenes)
count <- 0
for (i in 1:nSystems) {
	for (j in 1:sysSizes[i]) {
		count <- count + 1
		geneSys[count] <- i
	}
}


# Create the genePairs list of maximum possible size which we'll
# lazily take as the sum of squares of the systems.
# We'll drop unused rows when we're done.

genePairs <- matrix("", nrow=(sum(sysSizes^2)), ncol=6)
colnames(genePairs) <- c("geneA", "geneB", t(trackNames))

# Assign edges:
index <- 0
for (a in 1:(nGenes-1)) {
	for (b in (a+1):nGenes) {  # for all gene pairs ...
		if ( (geneSys[a] == geneSys[b] && (runif(1) <= pWithin )) ||
		     (geneSys[a] != geneSys[b] && (runif(1) <= pBetween)) ) {
				index <- index+1
				genePairs[index, "geneA"] <- a
				genePairs[index, "geneB"] <- b
		}
	} 
}
genePairs <- genePairs[1:index,]


# =================================================
# Part three: Assign weights for tracks
# =================================================

eB <- mapP2E(baseWeight)
for (pair in 1:nrow(genePairs)) {
	ePair <- rnorm(1, mean=eB, sd=baseSpread)
	for (i in 1:length(trackNames)) {
		eTrack <- rnorm(1, mean=ePair, sd=betweenTracksSpread)
		pTrack <- mapE2P(eTrack)
		if (pTrack < threshold) { pTrack <- 0.0 }
		genePairs[pair, trackNames[i]] <- sprintf("%1.4f", pTrack)
	}
}


# check deviations
# sds <- rep(0, nrow(genePairs))
# for (i in 1:nrow(genePairs)) {
#	sds[i] <- sd(as.numeric(genePairs[i,3:(2+length(trackNames))]))
# }
# hist(sds)

# =================================================
# Part four: Make gene labels
# =================================================


if (!require(combinat)) {
	install.packages("combinat")
	library(combinat)
}

# Create unique labels for the systems
nChar <- 1
if(nSystems > length(combn(LETTERS,1))) { nChar <- 2}
if(nSystems > length(combn(LETTERS,2))) { nChar <- 3}
if(nSystems > length(combn(LETTERS,3))) { nChar <- 4}

x <- t(combn(LETTERS,nChar))[1:nSystems,]
x <- cbind(x, c("")) # hack to ensure that there are at least two columns
prefixes <- rep("", nSystems)
for (i in 1:nSystems) {
	prefixes[i] <- paste(x[i,], collapse="")
}
# Create a Gene-Labels vector
geneLabels <- rep("", nGenes)
count <- 0
for (i in 1:nSystems) {
	for (j in 1:sysSizes[i]) {
		count <- count + 1
		geneLabels[count] <- sprintf("%s%03d", prefixes[i] ,j)
	}
}

# =================================================
# Part five: write output
# =================================================

# You'll have to write this to file, rather than to console ....

# Plain output:
# Tab delimited: gene A label, gene B label, 4 tracks
for (pair in 1:nrow(genePairs)) {
	cat(geneLabels[as.numeric(genePairs[pair, "geneA"])])
	cat("\t")
	cat(geneLabels[as.numeric(genePairs[pair, "geneB"])])
	for (i in 1:length(trackNames)) {
		cat("\t")
		cat(genePairs[pair, trackNames[i]])
	}
	cat("\n")
}

# Simple output with system IDs:
# Tab delimited: gene A index, gene B index, 1 track, System index A, System index B
for (pair in 1:nrow(genePairs)) {
	A <- as.integer(genePairs[pair, "geneA"])
	B <- as.integer(genePairs[pair, "geneB"])
	cat(A)
	cat("\t")
	cat(B)
	cat("\t")
	cat(genePairs[pair, trackNames[1]]) # use first track value only
	cat("\t")
	cat(geneSys[A])
	cat("\t")
	cat(geneSys[B])
	cat("\n")
}


# [Done]


