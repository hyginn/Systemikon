# Ready XML File for Writing
GenePWY_File <- xmlOutputDOM()
PWYenz_File <- xmlOutputDOM()

# Make a giant vector of pathway names
PWY_names_vec <- NULL

for (i in 1:nrow(LoG_File)) {

 # Access BioCyc Web-Based API and parse the XML file
 # For more information on the BioCyc API: http://biocyc.org/web-services.shtml
 # Subsitute BIOCYCID in the url with the actual BioCyc ID from LoG
 xml.url <- "http://websvc.biocyc.org/apixml?fn=pathways-of-gene&id=BIOCYCID&detail=None"
 xml.url <- gsub("BIOCYCID", LoG_BioCyc[i], xml.url)

 # Access URL as XML with Nodes
 PWY.xml = xmlRoot(xmlTreeParse(xml.url))

 # Obtain Pathway Names for the Gene ID
 namelist = getPATHNEnames(PWY.xml)
 PWY_names_vec <- unique(c(PWY_names_vec, namelist))

 # Make a node in he xml file for Genes: carrying pathway names
 # Remember
 GenePWY_File$addTag(LoG_NCBIGI[i], paste(namelist, collapse = ', '))
 }

# Make a matrix that's saved to memory that contains Pathway-Enzyme Information
PWYenz_mat <- matrix(0, length(PWY_names_vec))

for (i in 1:length(PWY_names_vec)) {
 # Obtain Enzyme Sets from this Pathways
 namelist <- getENZYMEnames(PWY_names_vec[i])

 # Replace the Matrix at Vertices
 PWYenz_mat[i] <- paste(namelist, collapse = ', ')
 }

# Rename Columns and Rows of Matrix
colnames(PWYenz_mat) <- c("Enzymes")
rownames(PWYenz_mat) <- PWY_names_vec

# Write Matrix to File
write.table(PWYenz_mat, file="PWYenz_Annotation_File.tab", append=FALSE,
row.names=TRUE, col.names=TRUE, sep="\t")

# Gene - Pathway Annotation File in XML format
# Output to GenePWY_File.xml
saveXML(GenePWY_File$value(), file="GenePWY_Annotation_File.xml")