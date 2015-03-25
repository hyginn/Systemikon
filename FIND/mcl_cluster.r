library(MCL)
library(igraph)

#This function takes in a file address and returns the normalied data
#contains the data frames
#The normalization of this 
normalize <- function(address){

  data <- read.table(address,header=TRUE, sep=" ")

  empirical_cdf1 <- ecdf(data[,3]) 
  empirical_cdf2 <- ecdf(data[,4])
  empirical_cdf3 <- ecdf(data[,5])
  empirical_cdf4 <- ecdf(data[,6])

  data[3] <- lapply(data[3],empirical_cdf1)
  data[4] <- lapply(data[4],empirical_cdf2)
  data[5] <- lapply(data[5],empirical_cdf3)
  data[6] <- lapply(data[6],empirical_cdf4)
  
  return(data)

}

#This function fuses the graphs together based on the shannon entropy

fusion <- function(data, size){
  answer <- data.frame(gene_id1 = numeric(size), gene_id2 = numeric(size),
                       edge_weight = numeric(size))
  for (i in 1:size){
    answer[i,1] <- data[i,1]
    answer[i,2] <- data[i,2]
    
    num <- c(data[i,3], data[i,4], data[i,5], data[i,6])
    num <- num/sum(num)
    answer[i,3] <- -sum(num*log2(num))
  }
  return (answer)
}

normalized_table <- normalize("sample1.txt")
data <- fusion(normalized_table, nrow(normalized_table))

all_names <- unique(c(data[,1], data[,2]))
adjacency_vector <- numeric(length(all_names)^2)

size = length(all_names)

new_index <- 1:size
names(new_index) <- all_names


for (i in 1:length(data[,1])){
  node1 <- data[i,1] 
  node2 <- data[i,2]
  data[i,1] <- new_index[toString(node1)]
  data[i,2] <- new_index[toString(node2)]
}

for (i in 1:length(data[,1])){
  node1 <- data[i,1]
  node2 <- data[i,2]
  adjacency_vector[(node1-1)*10 + node2] = data[i,3]
}

adjacency <- matrix(adjacency_vector, byrow=TRUE, nrow=size)
clusters <- mcl(adjacency, addLoops=TRUE)
