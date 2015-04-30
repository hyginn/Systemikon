# Systemikon/LIST
This folder contains code to create lists of gene identifiers for gene-pair annotation by the systemikon annotation tracks.

# Introduction
The List 2.0.py file exists to convert a given list into KEGG ID and Gene Symbols.

# Requirements
- Python
- urllib2 and json libraries (should be default)

#Genome - xxxx.txt
Homo sapiens lists in varying formats, tab delimited, to be used for analysis.

#input.txt
Sample input file.
The input is simply one line with a run identifier, one blank line, and then the list of genes to be converted on new lines:
Run00000

Gene01
Gene02
Gene03

#output.txt
This is the output file that will be edited, or added if it doesn’t exist. Make sure you rename each output as the code will simply overwrite this current file.

#Setup:
- Place your data in the input.txt file as needed.
- Open List 2.0.py and run it.
- Output should be in the output.txt file.

#To Do
- [ ] Change the output file from overwriting to creating a new file each time.