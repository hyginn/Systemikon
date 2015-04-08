getPATHNEnames <- function(doc) {
 namelist <- NULL
 for (i in 2:xmlSize(doc)) {
  node <- doc[i]
  name_str = toString(node)

  # Find string index for pathway name
  # Returns a starting index [1]
  search = "getxml?"
  len_search = nchar(search)
  start_index <- regexpr(search, name_str)
  temp_str <- substring(name_str, start_index + len_search)
  end_index <- regexpr(", ", temp_str)[1] - 2

  # Define substring that describes the pathway
  name <- substring(temp_str, 1, end_index)
 
  # Append Pathway Name to Vector
  namelist <- c(namelist, name)
  }
 namelist
 }

GenePWY_get <- function(node) {
 GenePWY_vec <- NULL
 name_str = toString(node)

 # Find string index for pathway name
 # Returns a starting index [1]
 search = "value = "
 len_search = nchar(search)
 start_index <- regexpr(search, name_str)
 temp_str <- substring(name_str, start_index + len_search + 1)
 end_index <- regexpr("namespace", temp_str)[1] - 6

 # Define substring that describes the pathway
 PWYs_str <- substring(temp_str, 1, end_index)
  
 # Divide string and form list
 PWYs_list <- strsplit(PWYs_str, ", ")

 # Append Pathway Name to Vector
 GenePWY_vec <- PWYs_list
 
 GenePWY_vec[[1]]
 }

GeneName_get <- function(node) {
 GeneName <- NULL
 name_str = toString(node)

 # Find string index for pathway name
 # Returns a starting index [1]
 search = "name = "
 len_search = nchar(search)
 start_index <- regexpr(search, name_str)
 temp_str <- substring(name_str, start_index + len_search + 1)
 end_index <- regexpr(", ", temp_str)[1] - 2

 # Define substring that describes the pathway
 GeneName_str <- substring(temp_str, 1, end_index)

 # Append Pathway Name to Vector
 GeneName <- GeneName_str
 
 GeneName
 }

getENZYMEnames <- function(Pathway) {
 # Access BioCyc REST-Based API to obtain enzymes of pathways
 Enzyme_xml.url <- "http://biocyc.org/apixml?fn=enzymes-of-pathway&id=BIOCYCID&detail=None"
 Enzyme_xml.url <- gsub("BIOCYCID", Pathway, Enzyme_xml.url)
 Enzyme.xml = xmlRoot(xmlTreeParse(Enzyme_xml.url))
 
 # Iterate over every node and extract out a list of enzyme BioCyc IDs
 namelist <- NULL
 for (i in 2:xmlSize(Enzyme.xml)) {
  node <- Enzyme.xml[i]
  name_str = toString(node)
  
  # Find string index for pathway name
  # Returns a starting index [1]
  search = "getxml?"
  len_search = nchar(search)
  start_index <- regexpr(search, name_str)
  temp_str <- substring(name_str, start_index + len_search)
  end_index <- regexpr(", ", temp_str)[1] - 2

  # Define substring that describes the pathway
  name <- substring(temp_str, 1, end_index)
 
  # Append Pathway Name to Vector
  namelist <- c(namelist, name)
  }
 namelist
 }

retrieveENZYMEnames <- function(Pathway) {
 # Append Pathway Name to Vector
 namelist <- strsplit(toString(PWYenz_mat[Pathway,]), ', ')[[1]]
 namelist
 }

PP_score <- function(PWYs_i,PWYs_j) {
 PwPw_score <- 0
 # Iterate over each pathway in each Pathway set
 for (a in PWYs_i) {
  for (b in PWYs_j) {
   if (a == b) {
    PwPw_score <- PwPw_score + 1}
   else {
    # Analyze the similarities between two different pathways
    enzymes_a <- retrieveENZYMEnames(a)
    enzymes_b <- retrieveENZYMEnames(b)
    
    # Merge the two sets of enzyme data
    enzymes_ab <- c(enzymes_a, enzymes_b)

    # Find number of repeated enzymes in the vector that
    # contains enzymes from both pathways (similarity #)
    # +1 to score if enz. exists in both, 0 otherwise
    # Find maximum number uniqe enzymes in each set
    PwPw_score <- PwPw_score + sum( duplicated(enzymes_ab) ) / length(unique(enzymes_ab))
    }
   }
  }
  PwPw_score
 }

getPATHNEnames <- cmpfun(getPATHNEnames)
GenePWY_get <- cmpfun(GenePWY_get)
GeneName_get <- cmpfun(GeneName_get)
getENZYMEnames <- cmpfun(getENZYMEnames)
retrieveENZYMEnames <- cmpfun(retrieveENZYMEnames)
PP_score <- cmpfun(PP_score)
