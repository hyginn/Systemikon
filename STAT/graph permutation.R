
library(igraph)
#READ the txt file into R data frame and make it graph
g<-read.graph("F:/study/university life/BIOINFO/bcb420/testfile.txt",format="ncol")
E(g)$weight
#Choose how many swapping edges you like to do, in this case 100
n<-100
s<- rewire(c, niter=n)
#output the data
edges<-data.frame(get.edgelist(s))
write.table(edges,file="edges.csv",sep=",")