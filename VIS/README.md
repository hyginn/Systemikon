# Systemikon/VIS
This folder contains the network and hierarchy visualization component of the Systemikon project.

# Introduction
The visualization framework reads a csv file and imports it as a graph into d3.js framework and display with a force directed layout.

# Requirements
- Any modern Browser
- Python

#d3.v2.js
The source file for d3.js. For more info visit http://d3js.org.

#edges9.csv
Sample input file.
The input is essentially an edgelist with three columns:
- Source: The source node of the edge.
- Target: The target node of the edge.
- Value: A numerical value (weight?) - currently this is used to calculate edge opacity.

#index.html
The main HTML file that runs the simulation.
The following feilds/lines are of interest when modifying the page for use:
- Lines 6-15: Default colors for nodes and edges (CSS).
- Lines 18-20: Format for text /labels.
- Line 28: var links = d3.csv("edges9.csv" ... : The name of the input edgelist file goes in the quotation marks.
- Line 33: var threshold: The This is the threshold that was set for the edges file that is used to scale edge opacity. For example, if the threshold is 0.9, the range [0.9,1.0] is expanded to [0,1] and used for opacities.
- Lines 43-46: Canvas / window dimensions.
- Line 56: "Charge" of the nodes. The lower the number, the more the nodes repell each other.

#Setup:
- Place your data in the VIS directory.
- Modify line 28 if needed to your input file name.
- Run the python server ("python runserver.py").
- In your browser go to 0.0.0.0:8000
- Have fun.

#Controls:
- Click a node to stop the force simulation.
- Click and drag nodes to modify layout.
- Double click a node to highlight its neighbors.
- Double clock again to restore to default.
- Scroll to zoom.

# TODO:
- [ ] Improve Style
- [ ] Add Controls like live thresholding
- [ ] ???
- [ ] Profit
