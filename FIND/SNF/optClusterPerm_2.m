%% Script to try multiple pWithin values from Prof. Steipe's code and output the NMI and estimated number of clusters
% Note, before this is executed, the system specific paths and R server
% must be installed. openR must be issued to open the R server
% This code generates a plot to compare NMI and cluster number as a
% function of the pWithin value

clear
clc

% First declare parameters
nSystems_range =[ 16 32 64 128] %The number of systems for synthetic data generation
nGenes_num = 2000; %Number of genes for synthetic data generation
pWithin_range = [0.01 0.1:0.075:0.9250 0.98] %[0.001 0.005 0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.4 0.8] %The values of pWithin to iterate over
makeGPMmatrixLocation = 'source("C:/Users/Naveen/Documents/makeGPMmatrix.R")'; %Path for makeGPMmatrix


K = 20;%number of neighbors, usually (10~30)
alpha = 0.5; %hyperparameter, usually (0.3~0.8)
T = 20; %Number of Iterations, usually (10~20)

count=0;
count_clusterNum = 0;
for nSystems_num = nSystems_range
    count_clusterNum = count_clusterNum + 1;
    fprintf('nSystems_num = %i \n',nSystems_num);
    count = 0;
    for pWithin_num = pWithin_range
        fprintf('pWithin_num = %f\n',pWithin_num);
        count = count + 1;
        [rawData groundTruth] = generateData(nGenes_num, nSystems_num, pWithin_num, makeGPMmatrixLocation);
        [W_ind] = generateAdjacencyMatrix(rawData);
        
        fprintf('Beginning SNF\n');
        W = SNF({W_ind{1},W_ind{2},W_ind{3},W_ind{4}}, K, T);
        fprintf('Completed SNF\n');
        
        %count
        %count_clusterNum
        fprintf('Estimating clusters for graph #');
        
        for graph_num = 1:5
            fprintf('%i......',graph_num);
            if graph_num < 5
                [A{graph_num}{count,count_clusterNum}(1) A{graph_num}{count,count_clusterNum}(2) A{graph_num}{count,count_clusterNum}(3) A{graph_num}{count,count_clusterNum}(4)] = ...
                    Estimate_Number_of_Clusters_given_graph(W_ind{graph_num}, [2:round(length(groundTruth)/15)]);
            else
                [A{graph_num}{count,count_clusterNum}(1) A{graph_num}{count,count_clusterNum}(2) A{graph_num}{count,count_clusterNum}(3) A{graph_num}{count,count_clusterNum}(4)] = Estimate_Number_of_Clusters_given_graph(W, [2:round(length(groundTruth)/15)]);
            end
            B{graph_num}{count}{count_clusterNum}(1) = pWithin_num;
            B{graph_num}{count}{count_clusterNum}(2) = nSystems_num;
        end
        fprintf('\n');
        
        %Store the data in the following matrix
        %[NMI(count) suggestedClusterNumber(count)]=SNFpermutation(rawData, groundTruth, nSystems_num);
    end
end

plotData;
