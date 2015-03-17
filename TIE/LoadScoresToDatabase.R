# Loading scores into the Systemikon database
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

# Name of scores file
fileName <- 'Total GoSemSim Scores.csv' 

## Add scores to scores table in systemikon database
data <- read.table(fileName, sep=',', header=TRUE)

apply(data, 1, function(row) {
  genePairID <- row["Gene.Pair"]
  gene1ID <- row["Gene.1"]
  gene2ID <- row["Gene.2"]
  score <- row["GOSEMScore"]
  
  # Insert gene pair into gene_pairs table first
  query <- paste('INSERT INTO gene_pairs VALUES (', 
                 paste(genePairID, ',', sep=''),
                 paste(gene1ID, ',', sep=''), 
                 gene2ID, 
                 ');'
  )
  dbSendQuery(con, query)
  
  # Insert score into scores table
  query <- paste('INSERT INTO scores VALUES (', 
                 paste(genePairID, ',', sep=''),
                 paste(score, ',', sep=''), 
                 '\'GOSEM\'', 
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