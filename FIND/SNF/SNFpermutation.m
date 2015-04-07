function [ SNFNMI, suggestedClusterNumber ] = SNFpermutation( rawData, groundTruth, C )
%SNFpermutation
%   This function takes rawData matrix, groundTruth and numberOfClusters
%   and returns the NMI and suggested number of clusters to determine how
%   accurate clustering is given different input data sets. This code is
%   verbose, but you can supress the tic toc and print lines to make it
%   silent

%% First, set all the parameters.
K = 20;%number of neighbors, usually (10~30)
alpha = 0.5; %hyperparameter, usually (0.3~0.8)
T = 20; %Number of Iterations, usually (10~20)

%rawData matrix should have the following form
%geneA geneB iRefScore GEOScore GOScore pathWScore
geneA = rawData(:,1);
geneB = rawData(:,2);
iRef = rawData(:,3);
GEO = rawData(:,4);
GO = rawData(:,5);
pathW = rawData(:,6);


%% Convert data to adjacency matrix format
fprintf('Creating adjacency matrices\n');
tic;
dataCat = [iRef GEO GO pathW];
for j=1:size(dataCat,2);
    for i=1:length(geneA)
        W_ind{j}(geneA(i),geneB(i)) = dataCat(i,j);
        W_ind{j}(geneB(i),geneA(i)) = W_ind{j}(geneA(i),geneB(i));
    end
end
fprintf('Created all adjacency matrices\n');
toc
fprintf('\n');

%% Fuse the graphs using SNF
tic;
fprintf('Beginning SNF\n');
W = SNF({W_ind{1},W_ind{2},W_ind{3},W_ind{4}}, K, T);
fprintf('Completed SNF\n');
toc
fprintf('\n');

%% Estimate Optimal Number of Clusters

% First Estimate the number of clusters using the average of the eigengab
% and roation cost score
[K1, K2, K12,K22] = Estimate_Number_of_Clusters_given_graph(W, [2:round(length(groundTruth)/15)]);
C = round(mean([K1 K12]));
suggestedClusterNumber = C;
%tic;
%fprintf('Beginning spectral clustering on SNF\n');
group = SpectralClustering(W,C);%%%the final subtypes information
%fprintf('Completed spectral clustering\n');
%toc
%fprintf('\n');

%% Evaluate goodness of clustering
%%%you can evaluate the goodness of the obtained clustering results by calculate Normalized mutual information (NMI): if NMI is close to 1, it indicates that the obtained clustering is very close to the "true" cluster information; if NMI is close to 0, it indicates the obtained clustering is not similar to the "true" cluster information.
[AR,RI,MI,HI]=RandIndex(group,groundTruth);
SNFNMI = Cal_NMI(group, groundTruth)

%fprintf('Some cluster comparison metrics against groundTruth:\nAdjusted Rand Index: %f\nUnadjusted Rand Index: %f\nMirkin Index: %f\nHubert Index: %f',AR,RI,MI,HI);
%fprintf('\n');

%displayClusters(W,group);

%%%you can also find the concordance between each individual network and the fused network
%ConcordanceMatrix = Concordance_Network_NMI({W,W_ind{1},W_ind{2},W_ind{3},W_ind{4}},C)
end

