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
PrandFile <- "PearsonMar18list.dat"
MICsetsFile <- "MICMar13list.dat"
MICrandFile <- "MICMar17list.dat"

setwd("C:/Atom/BCB420")

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
op <- par(mfrow = c(1, 2), pty="s")
plot(abs(Psets$Val), MICsets$Val, cex=0.5, pch=16, col="#FF000033")
plot(abs(Prand$Val), MICrand$Val, cex=0.5, pch=16, col="#0000FF33")
par(op)

# qqplots of Pearson vs. MIC
op <- par(mfrow = c(1, 2))
qqplot(abs(Psets$Val), MICsets$Val, cex=0.5, pch=16, col="#FF000007")
qqplot(abs(Prand$Val), MICrand$Val, cex=0.5, pch=16, col="#0000FF12")
par(op)

# END
#Begin research on lo MIC high pearson and high MIC low Pearson
table.interest<-cbind(MICsets,Psets[,3])
colnames(table.interest)<-c("GeneA","GeneB","MIC","Pearson")
table.random<-cbind(MICrand,Prand[,3])
colnames(table.random)<-c("GeneA","GeneB","MIC","Pearson")
exptable.whl<-rbind(exptable.interest,exptable.random)

loMIChiPrs<-rbind(subset(table.interest,table.interest[,"MIC"]<abs(table.interest[,"Pearson"])),subset(table.random,table.random[,"MIC"]<abs(table.random[,"Pearson"])))
loMIChiPrs<-loMIChiPrs[ order(abs(loMIChiPrs[,4])-loMIChiPrs[,3],decreasing=TRUE),]
hiMICloPrs<-rbind(subset(table.interest,table.interest[,"MIC"]>abs(table.interest[,"Pearson"])),subset(table.random,table.random[,"MIC"]>abs(table.random[,"Pearson"])))
hiMICloPrs<-hiMICloPrs[ order(-abs(hiMICloPrs[,4])+hiMICloPrs[,3],decreasing=TRUE),]

par(mfrow = c(2, 2))
	plot(exptable.interest[as.character(loMIChiPrs[1,1]),],exptable.interest[as.character(loMIChiPrs[1,2]),],xlab=as.character(loMIChiPrs[1,1]),ylab=as.character(loMIChiPrs[1,2]),cex=1, pch=16, col="#0000FF33")
	plot(exptable.interest[as.character(loMIChiPrs[2,1]),],exptable.interest[as.character(loMIChiPrs[2,2]),],xlab=as.character(loMIChiPrs[2,1]),ylab=as.character(loMIChiPrs[2,2]),cex=1, pch=16, col="#0000FF33")
	plot(exptable.interest[as.character(loMIChiPrs[3,1]),],exptable.interest[as.character(loMIChiPrs[3,2]),],xlab=as.character(loMIChiPrs[3,1]),ylab=as.character(loMIChiPrs[3,2]),cex=1, pch=16, col="#0000FF33")
	plot(exptable.interest[as.character(loMIChiPrs[4,1]),],exptable.interest[as.character(loMIChiPrs[4,2]),],xlab=as.character(loMIChiPrs[4,1]),ylab=as.character(loMIChiPrs[4,2]),cex=1, pch=16, col="#0000FF33")
title("Expression of top 4 (|Pearson|-MIC) gene pairs with Low MIC high Pearson Coefficient", line = -2, outer = TRUE)

par(mfrow = c(2, 2))
	plot(exptable.interest[as.character(hiMICloPrs[1,1]),],exptable.interest[as.character(hiMICloPrs[1,2]),],xlab=as.character(hiMICloPrs[1,1]),ylab=as.character(hiMICloPrs[1,2]),cex=1, pch=16, col="#0000FF33")
	plot(exptable.interest[as.character(hiMICloPrs[2,1]),],exptable.interest[as.character(hiMICloPrs[2,2]),],xlab=as.character(hiMICloPrs[2,1]),ylab=as.character(hiMICloPrs[2,2]),cex=1, pch=16, col="#0000FF33")
	plot(exptable.interest[as.character(hiMICloPrs[3,1]),],exptable.interest[as.character(hiMICloPrs[3,2]),],xlab=as.character(hiMICloPrs[3,1]),ylab=as.character(hiMICloPrs[3,2]),cex=1, pch=16, col="#0000FF33")
	plot(exptable.interest[as.character(hiMICloPrs[4,1]),],exptable.interest[as.character(hiMICloPrs[4,2]),],xlab=as.character(hiMICloPrs[4,1]),ylab=as.character(hiMICloPrs[4,2]),cex=1, pch=16, col="#0000FF33")
title("Expression of top 4 (MIC-|Pearson|) gene pairs with high MIC low Pearson Coefficient", line = -2, outer = TRUE)

par(mfrow = c(4, 2))
#plot 1,1 in hiMICloPrs
par(mai=c(3,0.5,1,0.5))
#barplot(exptable.whl[as.character(hiMICloPrs[4,1]),],axisnames=FALSE)
x<-barplot(exptable.whl[as.character(hiMICloPrs[4,1]),],axisnames=FALSE)
axis(1,at=x,labels=colnames(exptable.whl),cex.axis=0.75,las=2)
title(paste("EntrezID",hiMICloPrs[4,1]))


par(mai=c(3,0.5,1,0.5))
barplot(exptable.whl[as.character(hiMICloPrs[3,2]),],axisnames=FALSE)
#x<-barplot(exptable.whl[as.character(hiMICloPrs[3,2]),],axisnames=FALSE)
axis(1,at=x,labels=colnames(exptable.whl),cex.axis=0.75,las=2)
title(paste("EntrezID",hiMICloPrs[3,2]))

barplot.ttitle<-paste(paste("Gene Expression of hiMICloPrs accross tissue types")
title(barplot.ttitle,line=-2,outer=TRUE)


#plot 1,1 in loMIChiPrs
par(mai=c(3,0.5,1,0.5))
x<-barplot(exptable.whl[as.character(loMIChiPrs[4,2]),],axisnames=FALSE)
axis(1,at=x,labels=colnames(exptable.whl),cex.axis=0.75,las=2)
title(paste("EntrezID",loMIChiPrs[4,2]))

