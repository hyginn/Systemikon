%% Script to try multiple pWithin values from Prof. Steipe's code and output the NMI and estimated number of clusters
% Note, before this is executed, the system specific paths and R server
% must be installed. openR must be issued to open the R server
% This code generates a plot to compare NMI and cluster number as a
% function of the pWithin value

clear
clc

% First declare parameters
nSystems_num = 5; %The number of systems for synthetic data generation
nGenesStr = num2str(2000); %Number of genes for synthetic data generation
pWithinValues = [0.2 0.5 0.8]%[0.001 0.005 0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.4 0.8] %The values of pWithin to iterate over
makeGPMmatrixLocation = 'source("C:/Users/Naveen/Documents/makeGPMmatrix.R")'; %Path for makeGPMmatrix

K = 20;%number of neighbors, usually (10~30)
alpha = 0.5; %hyperparameter, usually (0.3~0.8)
T = 20; %Number of Iterations, usually (10~20)

count=0;
count_clusterNum = 0;
for nSystems_num = [ 128 64 32 16 8]
    count_clusterNum = count_clusterNum + 1;
    nSystems_num
    count = 0;
    for pWithin = [0.8 0.5 0.2 0.1]
        clear rawData
        pWithin
        count=count+1;
        
        %Prepare parameter for calling the R server
        nSystems = num2str(nSystems_num);
        pWithin_str = num2str(pWithin);
        Rinput = strcat('a <- makeGPMmatrix(nGenes=',nGenesStr,',','nSystems=',nSystems,',','pWithin=',pWithin_str,')');
        
        %Call the function in R and save the data to rawData
        evalR(makeGPMmatrixLocation);
        evalR(Rinput);
        rawData = getRdata('a');
        
        %Find number of genes as the max index
        nGenes = max(max(rawData(:,1:2)));
        
        for i=1:nGenes
            temp=[];
            temp = find(rawData(:,1)==i);
            if isempty(temp);
                temp = find(rawData(:,2)==i);
                groundTruth(i,1) = rawData(temp(1),8);
            else
                groundTruth(i,1) = rawData(temp(1),7);
            end
        end
        
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
        fprintf('Created all adjacency matrices\n');
        toc
        fprintf('\n');
        
        fprintf('Beginning SNF\n');
        W = SNF({W_ind{1},W_ind{2},W_ind{3},W_ind{4}}, K, T);
        fprintf('Completed SNF\n');
        
        count
        count_clusterNum
        for graph_num = 1:5
            graph_num
            if graph_num < 5
                [A{graph_num}{count,count_clusterNum}(1) A{graph_num}{count,count_clusterNum}(2) A{graph_num}{count,count_clusterNum}(3) A{graph_num}{count,count_clusterNum}(4)] = Estimate_Number_of_Clusters_given_graph(W_ind{graph_num}, [2:round(length(groundTruth)/15)]);
            else
                [A{graph_num}{count,count_clusterNum}(1) A{graph_num}{count,count_clusterNum}(2) A{graph_num}{count,count_clusterNum}(3) A{graph_num}{count,count_clusterNum}(4)] = Estimate_Number_of_Clusters_given_graph(W, [2:round(length(groundTruth)/15)]);
            end
            B{graph_num}{count}{count_clusterNum}(1) = pWithin;
            B{graph_num}{count}{count_clusterNum}(2) = nSystems_num;
        end
        
        %Store the data in the following matrix
        %[NMI(count) suggestedClusterNumber(count)]=SNFpermutation(rawData, groundTruth, nSystems_num);
    end
end
% figure;
% subplot(211)
% plot([0.001 0.005 0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.4 0.8],abs(NMI));
% xlabel('pWithin');
% ylabel('Normalized Mutual Information');
% subplot(212)
% plot([0.001 0.005 0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.4 0.8],suggestedClusterNumber)
% xlabel('pWithin');
% ylabel('Suggested Number of Clusters');