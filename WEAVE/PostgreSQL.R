library(RPostgreSQL)

## Load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## User information
username <- "postgres" # Change this
password <- 'postgres' # Change this
dbname <- 'systemikon'

con <- dbConnect(drv,
                 dbname=dbname,
                 user=user,
                 password=password,
                 host='localhost',
                 port='5432')

## Display connection summary
summary(con)

# Perform queries
dbSendQuery(con, "INSERT INTO genes VALUES (3073, 'hexosaminidase A (alpha polypeptide)', 'HEXA', 'Homo sapiens');")

dbSendQuery(con, "UPDATE genes SET organism='Human' WHERE symbol='BRCA1';")

genes <- dbGetQuery(con, "SELECT * FROM genes;")
print(genes)

dbSendQuery(con, "UPDATE genes SET organism='Homo sapiens' WHERE symbol='BRCA1';")

dbSendQuery(con, "DELETE FROM genes WHERE symbol='HEXA';")

## Close all open connections
for (con in dbListConnections(drv)) {
  dbDisconnect(con)
}

## Free all the resources used up by the driver
dbUnloadDriver(drv)