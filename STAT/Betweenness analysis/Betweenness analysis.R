#load igraph and input data
library(igraph)
g<-read.graph("F:/study/university life/BIOINFO/bcb420/testfile.txt",format="ncol")

#some setup
lay <- layout.fruchterman.reingold(g)
#Betweenness centrality plotted against eigenvector centrality
plot(evcent(g)$vector,betweenness(g))

text(evcent(g)$vector, betweenness(g), 0:length(V(g)), cex=0.7, pos=3)

#label point of interest with color
V(g)[1]$color<-"red"
V(g)[22]$color<-"green"
#plot network with highlighted point
plot(g, layout=lay, vertex.size=8, vertex.label.cex=0.6)