install.packages("igraph")
library(igraph)

s <- cbind(A=sample(letters[1:4], 100, replace=TRUE),
           B=sample(letters[1:2], 100, replace=TRUE))
s.tab <- table(s[,1], s[,2])

s.g <- graph.incidence(s.tab, weighted=T)
plot(s.g, layout=layout.circle, 
     vertex.label=c(letters[1:4],letters[2:1]),     
     vertex.color=c(rep("red",4),rep("red",2)), 
     edge.width=c(s.tab)/3, vertex.size=20, 
     vertex.label.cex=3, vertex.label.color="blue")
