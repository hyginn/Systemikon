knowceans-mcl

This package implements the Markov clustering (MCL) algorithm for graphs,
using a HashMap-based sparse representation of a Markov matrix, i.e., an
adjacency matrix m that is normalised to one. Elements in a column / node can
be interpreted as decision probabilities of a random walker being at that
node. For a more detailed description, see javadoc of MarkovClustering, or
Stijn van Dongen's thesis Graph Clustering by Flow Simulation (2000).

Author:    Gregor Heinrich (gregor :: arbylon . net)
Date:      3 Aug 2006
IDE:       Eclipse 3.2
Dependent: no dependencies
License:   General Public License, see source code.

Test:
Start the main method of the MarkovClustering class, which will load a
matrix from m.txt and run the MCL algorithm on it. This is the matrix
T(G3 + I) that was used by Stijn van Dongen (2000) to explain the
algorithm on page 50 of his thesis. Although m.txt is stored in dense format,
for larger problems, MatrixLoader contains a method to read sparse matrices
with the file format "rowindex columnindex value".

Also, for comparison I have put together a Matlab script, mcl.m that does
the same as the Java package, but with dense matrices.

If the package is to be used for larger problems, comment out the debug
output (calls to print()) in MarkovClustering.
