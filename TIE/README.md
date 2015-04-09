# Systemikon/TIE
This folder contains code to join and store gene-pair annotation data in the Systems Database.

In total there are 3 files:

1. ***LoadGenesToDatabase.R***: Loads the list of genes (LoG) into the *genes(gene\_id, gene\_symbol, description)* table in the Systemikon database
2. ***LoadScoresToDatabase.R***: Loads gene-pair scores into the *score(pair\_id, score, track\_symbol)* table in the Systemikon database
3. ***LoadTracksToDatabase.R***: Loads all available tracks into the *tracks(track\_symbol, track\_name)* table in the Systemikon database

More thorough documentation is provided in /doc/PostgreSQL/Systemikon\_Database\_Tutorial.html