install.packages("igraph")
library(igraph)

inputdata <- cbind(
           A=geneLabels,
           B=Track1Data,
           C=Track2Data,
           D=Track3Data,
           E=Track4Data)
tabledata <- table(s[,1], s[,2], s[,3], s[,4], s[,5])

#The following command creates a fused graph structure.
graph <- graph.incidence(tabledata, weighted=T) 

#Can visually confirm that the graph has the desired structure

#Sample code to check graph layout - this does not really work for the gene data...
#plot(graph, layout=layout.circle, 
#     vertex.label=c(letters[1:4],letters[2:1]),     
#     vertex.color=c(rep("red",4),rep("white",2)), 
#     edge.width=c(s.tab)/3, vertex.size=20, 
#     vertex.label.cex=3, vertex.label.color="blue")
