#read data file
gpm<-read.table("F:/study/university life/BIOINFO/bcb420/dataforRui.csv",sep=",")
#extract column 1 and 7,gene ID and system ID
sl<-gpm[,c(1,7)]
sl<-cbind(sl,gpm[,c(2,8)])
#extract unique columns
n<-unique(sl[,c(1,2)])
#Do numerical permutation in the data
n[,1]=sample(n[,1])
n[,2]=sample(n[,2])
#replace permutated data into original data
for (i in 1:length(n[,1])){
  p=match(gpm[i,1],n[,1])
  q=n[p,2]
  gpm[i,7]<-q
}

for (i in 1:length(n[,2])){
  p=match(gpm[i,2],n[,1])
  q=n[p,2]
  gpm[i,8]<-q
}
#Output permutated data
write.table(gpm,file="numericalpermute.csv",sep=",")


#Output a size data for powerlaw analysis
c<-table(n[,2])
e<-data.frame(c)
f<-sort(e[,2],decreasing=TRUE)
write.table(f,file="size.csv",sep=",")