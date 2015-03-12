# Systemikon/VIS
This folder contains the network and hierarchy visualization component of the Systemikon project.

# Introduction
The Visualization uses R to convert a tabular formatted input file into JSON which is then visualized using Cytoscape.

#makeGraph
Build a graph from Edge-list network graph file.

INPUT: See testInput.txt for sample input file, http://lgl.sourceforge.net/#FileFormat for format information.
OUTPUT: See testOutput.json.

##getDependencies.R
This script will install the required R packages.
Usage:
```
source("getDependencies.R")
```
##CytMake.R
This script contains the functions for converting an Edge-list network graph file to the required JSON for Cytoscape.

Usage:
```
source("CytMake.R")
graphToJSON("InputFile.txt")
```
This will write a "testOutput.json" file to your current working directory which can be fed into javascripts in the next step.

#site
The files required for running the graph reside in this directory. The input filename of the graph json can be changed if needed in "code.js".

To view the graph, open "main.html" in a browser.

Controls:
- Click and drag nodes to modify layout.
- Select an edge to view the edge weight.
- To select multiple edges, hold shift.

# TODO:
- [ ] Integrate with Clustering
- [ ] Improve Style
- [ ] Add Controls for randomizing views
- [ ] ???
- [ ] Profit
