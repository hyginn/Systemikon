# Loading tracks into the Systemikon database
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

# Add 4 tracks to database
dbSendQuery(con, 'INSERT INTO tracks VALUES(\'INTERACT\', \'protein-protein interaction pairscores\');')
dbSendQuery(con, 'INSERT INTO tracks VALUES(\'COEX\', \'co-expression pairscores\');')
dbSendQuery(con, 'INSERT INTO tracks VALUES(\'PATHNE\', \'pathway neighbour pairscores\');')
dbSendQuery(con, 'INSERT INTO tracks VALUES(\'GOSEM\', \'gene ontology semantic similarity pairscores\');')

## Close all open connections
for (con in dbListConnections(drv)) {
  dbDisconnect(con)
}

## Free all the resources used up by the driver
dbUnloadDriver(drv)
