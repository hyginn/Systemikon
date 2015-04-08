# Systemikon/VIS
This folder contains the network and hierarchy visualization component of the Systemikon project.

# Introduction
The visualization framework reads a csv file and imports it as a graph into d3.js framework and display with a force directed layout.

# Requirements
- Any modern Browser
- Python

#d3.v2.js
The source file for d3.js. For more info visit http://d3js.org.

#edges9.csv and links.csv
Sample input file(s) for edges.
The input is essentially an edgelist with three comma separated columns:
- Source: The source node of the edge.
- Target: The target node of the edge.
- Value: A numerical value (weight?) - currently this is used to calculate edge opacity.

#nodes.csv
Sample input file for Nodes and the clusters
The file is a comma seperated file with two columns:
- name: The name of the node / gene (corresponding to a Source or a Target in the edgelist).
- group: An identifier for the "group" or a "cluster" that the node / gene belongs to.

#index.html
The main HTML file that runs the simulation.
The following feilds/lines are of interest when modifying the page for use:
- Lines 6-15: Default colors for nodes and edges (CSS).
- Lines 18-20: Format for text /labels.
- Line 26: var edgeFile = "links.csv"; : The name of the input edgelist file goes inside the quotation marks.
- Line 37: var nodeClusterFile = "nodes.csv"; : The name of the input nodes/cluster pairing file goes inside the quoation marks.
- Line 52: var threshold: The This is the threshold that was set for the edges file that is used to scale edge opacity. For example, if the threshold is 0.9, the range [0.9,1.0] is expanded to [0,1] and used for opacities.
- Lines 56-59: Canvas / window dimensions.
- Line 61: "Linkdistance" is the default minimum distance between two connected nodes.
- Line 67: "Charge" of the nodes.The charge property acts like electrical charge on the nodes. With force-directed graphs in particular, charge causes nodes in the graph to repel each other. This behavior is generally desirable because it tends to prevent the nodes from overlapping each other in the visualization. The lower the number, the more the nodes repell each other.

#Setup:
- Place your data in the VIS directory.
- Modify lines 26 and 37 if needed to your input file name.
- Run the python server ("python runserver.py").
- In your browser go to 0.0.0.0:8000
- Have fun.

#Controls:
- Click/drag a node to stop the force simulation.
- Click and drag nodes to modify layout.
- Double click a node to highlight the nodes in the same cluster as the node clicked.
- Single click a node to highlight the nodes neighboring the node clicked.
- Double click or single click again to restore to default.
- Scroll to zoom.

# TODO:
- [ ] Improve Style
- [ ] Add Controls like live thresholding
- [ ] ???
- [ ] Profit
