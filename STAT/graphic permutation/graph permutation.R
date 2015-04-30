
library(igraph)
#READ the txt file into R data frame and make it graph
g<-read.graph("F:/study/university life/BIOINFO/bcb420/testfile3.txt",format="edgelist")

E(g)$weight
#Choose how many swapping edges you like to do, in this case 100
n<-300
s<- rewire(g,niter=300)
a<-data.frame(get.edgelist(g))
b<-data.frame(get.edgelist(s))
#output the data
edges<-data.frame(get.edgelist(s))
write.table(edges,file="edges.csv",sep=",")