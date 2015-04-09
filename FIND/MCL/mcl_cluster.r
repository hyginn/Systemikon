library(MCL)
library(igraph)

# This function takes in a file address and returns the normalied data
# Contains the data frames
# The normalization used in this function utilizes the emprical cumulative distrubution function method
# The reason for this normalization is to address the fact that multiple tracks can have scores within different ranges
# The normalization resolves this problem and provides further ground for further graph fusion

normalize <- function(address){

  data <- read.table(address,header=TRUE, sep=" ") # Reads the innput file 

  empirical_cdf1 <- ecdf(data[,3]) # Find the empircal cumulative distrubution function for track1
  empirical_cdf2 <- ecdf(data[,4]) # Find the empircal cumulative distrubution function for track2
  empirical_cdf3 <- ecdf(data[,5]) # Find the emprical cumulative distrubution function for track3
  empirical_cdf4 <- ecdf(data[,6]) # Find the empircal cumulative distrubution function for track4

  data[3] <- lapply(data[3],empirical_cdf1) # Apply the ecdf to track 1 
  data[4] <- lapply(data[4],empirical_cdf2) # Apply the ecdf for track 2
  data[5] <- lapply(data[5],empirical_cdf3) # Apply the ecdf for track 3
  data[6] <- lapply(data[6],empirical_cdf4) # Apply the ecdf for track 4
  
  return(data) # returns the data

}

# This function fuses the graphs together based on the Shannon entropy
# The reason for this fusion method is to address how consistant is the gene pair interaction scoe across different tracks
# This also addresses the fact that if one of the track has a high score, the shannon will be low, hance the association is high

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

# This function takes the ouput of the MCL function and writes the data into a file of user's choice
# data: The output put of the MCL function
# address: The string which represents the address of the file where the output should go
#          If full path is not specified, then the file will be created in the current working directory

write_results <- function(data, address){
  
  clusters = data$Cluster # Obtain the cluster data from the data fram output from the mcl function
  size <- length(clusters) # Obtain the total number of genes
  
  data <- data.frame(gene_id = numeric(size), cluster_number=numeric(size)) # Initialize the data frame
  
  # Populate the data frame which the data from the clusters
  for (i in 1:length(size)){
    data[i,1] = i
    data[i,2] = clusters[i]
  }
  
  write.table(d, address) # Write the output
  
}

normalized_table <- normalize("sample1.txt")
data <- fusion(normalized_table, nrow(normalized_table))

all_names <- unique(c(data[,1], data[,2])) # Obtain all unique names of the given gene ids
adjacency_vector <- numeric(length(all_names)^2) # Initializing the adjancy_vector

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
  adjacency_vector[(node1-1)*size + node2] = data[i,3]
  adjacency_vector[(node2-1)*size + node1] = data[i,3]
}

adjacency <- matrix(adjacency_vector, byrow=TRUE, nrow=size)
clusters <- mcl(adjacency, addLoops=TRUE)
write_results(clusters, "sample_output.txt")
