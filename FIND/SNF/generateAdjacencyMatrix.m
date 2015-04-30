function [ adjacencyMatrices ] = generateAdjacencyMatrix( rawData )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
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
    for n=1:length(geneA)
        W_ind{j}(geneA(n),geneB(n)) = dataCat(n,j);
        W_ind{j}(geneB(n),geneA(n)) = W_ind{j}(geneA(n),geneB(n));
    end
end

adjacencyMatrices = W_ind;
fprintf('Created all adjacency matrices\n');
toc
fprintf('\n');
end

