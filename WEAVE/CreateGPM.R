# Constructing the GPM (Gene Pairscore Multigraph)
# author: Victor Kofia
# date: 2015-04-08

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

# Get the result set
rs <- dbSendQuery(con, 'SELECT * FROM gene_pairs;')

## fetch all elements from the result set
genePairs <- fetch(rs,n=-1)

GPM <- data.frame(pid=integer(0), score=numeric(0), track=character(0), version=character(0))

apply(genePairs, 1, function(row) {
  pairId <- row["pid"]
  trackSymbols <- dbGetQuery(con, "SELECT tsymbol FROM tracks;")
  apply(trackSymbols, 1, function(trackSymbol) {
    rs <- dbSendQuery(con, paste('SELECT * FROM scores WHERE pid = ', 
                                 pairId, ' AND track = \'', trackSymbol, '\';', 
                                 sep=''))
    scores <- fetch(rs, n=-1)
    GPM <- rbind(GPM, scores)
  })
})

write.table(GPM, file='synthetic_GPM.csv', sep=',')

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