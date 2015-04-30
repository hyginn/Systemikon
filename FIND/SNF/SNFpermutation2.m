function [ NMI, K1 ] = SNFpermutation( W_ind, groundTruth, C )
%SNFpermutation
%   This function takes rawData matrix, groundTruth and numberOfClusters
%   and returns the NMI and suggested number of clusters to determine how
%   accurate clustering is given different input data sets. This code is
%   verbose, but you can supress the tic toc and print lines to make it
%   silent

K = 20;%number of neighbors, usually (10~30)
alpha = 0.5; %hyperparameter, usually (0.3~0.8)
T = 20; %Number of Iterations, usually (10~20)
%% Fuse the graphs using SNF
tic;
fprintf('Beginning SNF\n');
W = SNF({W_ind{1},W_ind{2},W_ind{3},W_ind{4}}, K, T);
fprintf('Completed SNF\n');
toc
fprintf('\n');

%% Estimate Optimal Number of Clusters
for i=1:length(W_ind);
    [K1(i), K2(i), K12(i),K22(i)] = Estimate_Number_of_Clusters_given_graph(W, [2:round(length(groundTruth)/15)]);
    group = SpectralClustering(W_ind{i},K1(i));
    NMI(i) = Cal_NMI(group, groundTruth);
end

K1(5) = Estimate_Number_of_Clusters_given_graph(W, [2:round(length(groundTruth)/15)]);

C = round(mean(K1));
%suggestedClusterNumber = C;
%tic;
%fprintf('Beginning spectral clustering on SNF\n');
group = SpectralClustering(W,C);%%%the final subtypes information
%fprintf('Completed spectral clustering\n');
%toc
%fprintf('\n');

%% Evaluate goodness of clustering
%%%you can evaluate the goodness of the obtained clustering results by calculate Normalized mutual information (NMI): if NMI is close to 1, it indicates that the obtained clustering is very close to the "true" cluster information; if NMI is close to 0, it indicates the obtained clustering is not similar to the "true" cluster information.
%[AR,RI,MI,HI]=RandIndex(group,groundTruth);
NMI(5) = Cal_NMI(group, groundTruth)

%fprintf('Some cluster comparison metrics against groundTruth:\nAdjusted Rand Index: %f\nUnadjusted Rand Index: %f\nMirkin Index: %f\nHubert Index: %f',AR,RI,MI,HI);
%fprintf('\n');

%displayClusters(W,group);

%%%you can also find the concordance between each individual network and the fused network
%ConcordanceMatrix = Concordance_Network_NMI({W,W_ind{1},W_ind{2},W_ind{3},W_ind{4}},C)
end

