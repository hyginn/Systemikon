# Constructing the GPM (Gene Pairscore Multigraph)
# author: Victor Kofia
# date: 2015-04-08

library(RPostgreSQL)

## Load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## User information
username <- 'postgres' # (??)
password <- 'postgres' # Change this
dbname <- 'systemikon'

con <- dbConnect(drv,
                 dbname=dbname,
                 user=username,
                 password=password,
                 host='localhost', # change this
                 port='5432') # change this

# Get the result set
rs <- dbSendQuery(con, 'SELECT * FROM gene_pairs;')

## fetch all elements from the result set
genePairs <- fetch(rs,n=-1)

GPM <- 

apply(genePairs, 1, function(row) {
  pairId <- row["pid"]
  trackSymbols <- dbGetQuery(con, "SELECT tsymbol FROM tracks;")
  apply(trackSymbols, 1, function(trackSymbol) {
    rs <- dbSendQuery(con, paste('SELECT * FROM scores WHERE pid = ', 
                                 pairId, ' AND track = \'', trackSymbol, '\';', 
                                 sep=''))
    scores <- fetch(rs, n=-1)
    print(scores)
  })
})

# Free up resources used by result set
for (rs in dbListResults(con)) {
  dbClearResult(rs)
}

## Close all open connections
for (con in dbListConnections(drv)) {
  dbDisconnect(con)
}

## Free all the resources used up by the driver
dbUnloadDriver(drv)