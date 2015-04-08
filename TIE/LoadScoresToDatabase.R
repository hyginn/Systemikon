# Loading scores into the Systemikon database
# author: Victor Kofia
# date: 2015-03-17

library(RPostgreSQL)

## Load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## User information
username <- '[INSERT USERNAME HERE]'
password <- '[INSERT PASSWORD HERE]'
dbname <- 'systemikon'

## Connect to the database
con <- dbConnect(drv,
                 dbname=dbname,
                 user=username,
                 password=password,
                 host='[INSERT HOST HERE]',
                 port='[INSERT PORT HERE]')

## Get track symbols
trackSymbols <- dbGetQuery(con, "SELECT tsymbol FROM tracks;")

apply(trackSymbols, 1, function(trackSymbol) {
  fileName <- paste('synthetic_', trackSymbol, '_G2G.csv', sep='')
  ## Add scores to scores table in systemikon database
  data <- read.table(fileName, sep=',')
  version <- paste(data[2,1])
  data <- data[-c(1, 2, 3), ]
  apply(data, 1, function(row) {
    genePairID <- row[1]
    gene1ID <- row[2]
    gene2ID <- row[3]
    score <- row[4]
    # Insert score into scores table
    query <- paste('INSERT INTO scores VALUES (', 
                   paste(genePairID, ',', sep=''),
                   paste(score, ',', sep=''), 
                   paste('\'', trackSymbol, '\'', ',', sep=''),
                   paste('\'', version, '\'', sep=''), 
                   ');'
    )
    dbSendQuery(con, query)
  })
})

## Close all open connections
for (con in dbListConnections(drv)) {
  dbDisconnect(con)
}

## Free all the resources used up by the driver
dbUnloadDriver(drv)