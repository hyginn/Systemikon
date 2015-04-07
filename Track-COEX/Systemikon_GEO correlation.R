library(Biobase)
library(GEOquery)
library(limma)
library(minerva)

# Load series and platform data from GEO ...
gset <- getGEO("GSE1133", GSEMatrix =TRUE)
 
if (length(gset) > 1) idx <- grep("GPL96", attr(gset, "names")) else idx <- 1
gset <- gset[[idx]]
# note: GPL96 is human. GPL1073 and GPL1074 are for mouse

# Check what we have
head(gset)

sml<- read.table("C:/Atom/BCB420/sample.txt",header = TRUE,sep="\t")
gset$description <- sml[,2]

# log2 transform
ex <- exprs(gset)
qx <- as.numeric(quantile(ex, c(0., 0.25, 0.5, 0.75, 0.99, 1.0), na.rm=T))
LogC <- (qx[5] > 100) ||
          (qx[6]-qx[1] > 50 && qx[2] > 0) ||
          (qx[2] > 0 && qx[2] < 1 && qx[4] > 1 && qx[4] < 2)
if (LogC) { ex[which(ex <= 0)] <- NaN
  exprs(gset) <- log2(ex) }

 
# load NCBI platform annotation
gpl <- annotation(gset)
platf <- getGEO(gpl, AnnotGPL=TRUE)
ncbifd <- data.frame(attr(dataTable(platf), "table"))

#constructing expression table
exptable<-exprs(gset)
colnames(exptable)<-sml[,2]
entrezid<-ncbifd[,c("ID","Gene.ID")]
rownames(entrezid)<-entrezid[,"ID"]
exptable.EID<-exptable[rownames(subset(entrezid,Gene.ID!="")),]
rownames(exptable.EID)<-entrezid[rownames(exptable.EID),"Gene.ID"]

#test group by Boris from Mar 13, 2015
test.gene<-as.character(read.csv("C:/Atom/BCB420/testgenes.csv", header=FALSE)[,1])
exptable.interest<-exptable.EID[intersect(test.gene,rownames(exptable.EID)),]
#exptable.interest<-exptable.EID

#Generate MIC for each gene pairs
MIC.val<-NA
GeneA<-NA
GeneB<-NA
for (i in 1:(nrow(exptable.interest)-1)) {
	for (j in 1:(nrow(exptable.interest)-i)){
		a<-mine(exptable.interest[i,],exptable.interest[i+j,])$MIC
		MIC.val<-c(MIC.val,a)
		GeneA<-c(GeneA,rownames(exptable.interest)[i])
		GeneB<-c(GeneB,rownames(exptable.interest)[i+j])
		}
	}
MIC.table<-cbind(GeneA,GeneB,MIC.val)[-1,]
#write.table(MIC.table,"C:/Atom/BCB420/MICMar13list.txt", sep="\t")
for (i in 1:nrow(MIC.table)){
	cat(MIC.table[i,"GeneA"],MIC.table[i,"GeneB"],MIC.table[i,"MIC.val"],file="C:/Atom/BCB420/MICMar13list.dat",sep="\t",append=TRUE)
	cat("\n", file="C:/Atom/BCB420/MICMar13list.dat", append=TRUE)
				}


#Generate Pearson cor for each gene pair, just for comparsion
Pearson.val<-NA
#GeneA<-NA
#GeneB<-NA
for (i in 1:(nrow(exptable.interest)-1)) {
	for (j in 1:(nrow(exptable.interest)-i)){
	a<-cor(exptable.interest[i,],exptable.interest[i+j,],method="pearson")
	Pearson.val<-c(Pearson.val,a)
#		GeneA<-c(GeneA,rownames(exptable.interest)[i])
#		GeneB<-c(GeneB,rownames(exptable.interest)[i+j])
		}
	}
Pearson.table<-cbind(GeneA,GeneB,Pearson.val)[-1,]
#write.table(Pearson.table,"C:/Atom/BCB420/PearsonMar13list.txt", sep="\t")
for (i in 1:nrow(Pearson.table)){
	cat(Pearson.table[i,"GeneA"],Pearson.table[i,"GeneB"],Pearson.table[i,"Pearson.val"],file="C:/Atom/BCB420/PearsonMar13list.dat",sep="\t",append=TRUE)
	cat("\n", file="C:/Atom/BCB420/PearsonMar13list.dat", append=TRUE)
				}



#limitations: have not picked out probes with on same Gene - some are isoforms, will deal with it
#
#find MIC>0.7
#subset(MIC.table,MIC.table[,"MIC.val"]>0.7)
#subset(PearsonCor.vector,PearsonCor.vector>0.7)


#random group by Boris from Mar 18, 2015
random.gene<-as.character(read.csv("C:/Atom/BCB420/randomgenes.csv", header=FALSE)[,1])
exptable.random<-exptable.EID[intersect(random.gene,rownames(exptable.EID)),]
#Generate MIC for each gene pairs
MIC.val.random<-NA
GeneA<-NA
GeneB<-NA
for (i in 1:(nrow(exptable.random)-1)) {
	for (j in 1:(nrow(exptable.random)-i)){
		a<-mine(exptable.random[i,],exptable.random[i+j,])$MIC
		MIC.val.random<-c(MIC.val.random,a)
		GeneA<-c(GeneA,rownames(exptable.random)[i])
		GeneB<-c(GeneB,rownames(exptable.random)[i+j])
		}
	}
MIC.table.random<-cbind(GeneA,GeneB,MIC.val.random)[-1,]
for (i in 1:nrow(MIC.table.random)){
	cat(MIC.table.random[i,"GeneA"],MIC.table.random[i,"GeneB"],MIC.table.random[i,"MIC.val.random"],file="C:/Atom/BCB420/MICMar17list.dat",sep="\t",append=TRUE)
	cat("\n", file="C:/Atom/BCB420/MICMar17list.dat", append=TRUE)
				}



#Generate Pearson cor for each gene pair, just for comparsion
Pearson.val.random<-NA
#GeneA<-NA
#GeneB<-NA
for (i in 1:(nrow(exptable.random)-1)) {
	for (j in 1:(nrow(exptable.random)-i)){
	a<-cor(exptable.random[i,],exptable.random[i+j,],method="pearson")
	Pearson.val.random<-c(Pearson.val.random,a)
#		GeneA<-c(GeneA,rownames(exptable.random)[i])
#		GeneB<-c(GeneB,rownames(exptable.random)[i+j])
		}
	}
Pearson.table.random<-cbind(GeneA,GeneB,Pearson.val.random)[-1,]
#write.table(Pearson.table.random,"C:/Atom/BCB420/PearsonMar17list.txt", sep="\t")
for (i in 1:nrow(Pearson.table.random)){
	cat(Pearson.table.random[i,"GeneA"],Pearson.table.random[i,"GeneB"],Pearson.table.random[i,"Pearson.val.random"],file="C:/Atom/BCB420/PearsonMar18list.dat",sep="\t",append=TRUE)
	cat("\n", file="C:/Atom/BCB420/PearsonMar18list.dat", append=TRUE)
				}

