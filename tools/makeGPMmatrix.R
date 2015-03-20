# makeGPMmatrix
# function to output a GPM-like matrix for matlab use
# see synthGPM.R for details
# B. Steipe, March 2015
#
# =====================

makeGPMmatrix <- function(nGenes = 100,
                         nSystems = 5,
                         pWithin = 0.8,
                         meanDegree = 10,
                         trackNames = c("iRef", "GEO", "GO", "pathW"),
                         baseWeight = 0.8,
                         baseSpread = 2,
                         betweenTracksSpread = 2,
                         threshold = 0.5
                         ) {
                         	
	pBetween <- ((1 - pWithin) * meanDegree * nGenes) / 
	            (((nGenes^2)-nGenes)/2)

	# Determine system sizes:
	
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

	# Assign edges
	geneSys <- rep(0, nGenes)
	count <- 0
	for (i in 1:nSystems) {
		for (j in 1:sysSizes[i]) {
			count <- count + 1
			geneSys[count] <- i
		}
	}

	genePairs <- matrix(0, nrow=(sum(sysSizes^2)), ncol=8)
	colnames(genePairs) <- c("geneA", "geneB", t(trackNames), "sysA", "sysB")
		
	# Assign edges:
	index <- 0
	for (a in 1:(nGenes-1)) {
		for (b in (a+1):nGenes) {  # for all gene pairs ...
			if ( (geneSys[a] == geneSys[b] && (runif(1) <= pWithin )) ||
			     (geneSys[a] != geneSys[b] && (runif(1) <= pBetween)) ) {
					index <- index+1
					genePairs[index, "geneA"] <- a
					genePairs[index, "geneB"] <- b
					genePairs[index, "sysA"] <- geneSys[a]
					genePairs[index, "sysB"] <- geneSys[b]
			}
		} 
	}
	genePairs <- genePairs[1:index,] # truncate to rows that were actually used

	# Assign weights for tracks
	
	eB <- mapP2E(baseWeight)
	for (pair in 1:nrow(genePairs)) {
		ePair <- rnorm(1, mean=eB, sd=baseSpread)
		for (i in 1:length(trackNames)) {
			eTrack <- rnorm(1, mean=ePair, sd=betweenTracksSpread)
			pTrack <- mapE2P(eTrack)
			if (pTrack < threshold) { pTrack <- 0.0 }
			genePairs[pair, trackNames[i]] <- pTrack
		}
	}
	
	return(genePairs)
}


