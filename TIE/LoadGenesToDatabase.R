# Loading LoG (List of Genes) into the Systemikon database
# author: Victor Kofia
# date: 2015-03-17

library(RPostgreSQL)

## Load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## User information
username <- 'postgres'
password <- 'postgres'
dbname <- 'systemikon'

## Connect to the database
con <- dbConnect(drv,
                 dbname=dbname,
                 user=username,
                 password=password,
                 host='localhost',
                 port='5432')

## Name of genes file
fileName <- 'listofgenes.txt' 

## Add genes to genes table in systemikon database
data <- read.table(fileName, sep='\t', header=TRUE)

apply(data, 1, function(row) {
  entrezID <- row["Entrez.ID"]
  symbolID <- row["Symbol.ID"]
  description <- row["Description"]
  query <- paste('INSERT INTO genes VALUES (', 
                 paste(entrezID, ',', sep=''), 
                 paste('\'', symbolID, '\'', ',', sep=''), 
                 paste('\'', description, '\'', sep=''), 
                 ');'
                 )
  dbSendQuery(con, query)
})

## Close all open connections
for (con in dbListConnections(drv)) {
  dbDisconnect(con)
}

## Free all the resources used up by the driver
dbUnloadDriver(drv)
