clc
clear
close all

%Generate the data
nGenes = num2str(2000);
nSystems = num2str(64);
pWithin = num2str(0.2);
Rinput = strcat('a <- makeGPMmatrix(nGenes=',nGenes,',','nSystems=',nSystems,',','pWithin=',pWithin,')');

evalR('source("C:/Users/Naveen/Documents/makeGPMmatrix.R")');
evalR(Rinput);
rawData = getRdata('a');

%Find number of genes as the max index
nGenes = max(max(rawData(:,1:2)));
%nGenes = rawData(max(1));

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


%%Load the data
%load BS_rawData_thresh0.1.mat;
%load BS_rawData_thresh0.1_pBetween0.2.mat;
%
%%%First, set all the parameters.
K = 20;%number of neighbors, usually (10~30)
alpha = 0.5; %hyperparameter, usually (0.3~0.8)
T = 20; %Number of Iterations, usually (10~20)
C = 32;%%%number of clusters
dataSaveName = '../../Data/nG20000-nSys-200-pWith-0.4.mat';

%rawData = csvread('../../../../Data/matlabImportData.csv');
geneA = rawData(:,1);
geneB = rawData(:,2);
iRef = rawData(:,3);
GEO = rawData(:,4);
GO = rawData(:,5);
pathW = rawData(:,6);

%groundTruth = csvread('../../../../Data/matlabImportTruth.csv');
save(dataSaveName);
%Prepare data in adjacency matrix from BS R code (manually imported)

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

%If the data are all continuous values, we recommend the users to perform standard normalization before using SNF, though it is optional depending on the data the users want to use. 

%Data1 = Standard_Normalization(data1);
%Data2 = Standard_Normalization(data2);

%%%Calculate the pair-wise distance; If the data is continuous, we recommend to use the function "dist2" as follows;
%if the data is discrete, we recommend the users to use chi-square distance
% Dist1 = dist2(Data1,Data1);
% Dist2 = dist2(Data2,Data2);

% W1 = adj_mat{1};
% W2 = adj_mat{2};
% W3 = adj_mat{3};
% W4 = adj_mat{4};

%%%next, construct similarity graphs - we already have these, no need to
%%%construct them
% W1 = affinityMatrix(Dist1, K, alpha);
% W2 = affinityMatrix(Dist2, K, alpha);
% W3 = affinityMatrix(Dist3, K, alpha);
% W4 = affinityMatrix(Dist4, K, alpha);

% W_ind{1} = W1;
% W_ind{2} = W2;
% W_ind{3} = W3;
% W_ind{4} = W4;


% for i=1:length(adj_mat)
%     W_ind{i} = adj_mat{i};
% end

%%% These similarity graphs have complementary information about clusters.
% displayClusters(W1,groundTruth);
% displayClusters(W2,groundTruth);



%%%%With this unified graph W of size n x n, you can do either spectral clustering or Kernel NMF. If you need help with further clustering, please let us know. 
%%for example, spectral clustering

fprintf('Beginning individual graph clustering\n');
for i=1:size(dataCat,2);
    tic;
    ind_group{i} = SpectralClustering(W_ind{i},C);
    fprintf('Clustered graph: #%i\n',i);
    toc
end
fprintf('\n');

tic;
fprintf('Beginning SNF\n');
%next, we fuse all the graphs
% then the overall matrix can be computed by similarity network fusion(SNF):
W = SNF({W_ind{1},W_ind{2},W_ind{3},W_ind{4}}, K, T);
fprintf('Completed SNF\n');
toc
fprintf('\n');

tic;
fprintf('Beginning spectral clustering on SNF\n');
group = SpectralClustering(W,C);%%%the final subtypes information
fprintf('Completed spectral clustering\n');
toc
fprintf('\n');

% %%%%%%Calculate accuracy based on ground truth
% %%First, we rearrange the matrix to have a list of genes associated to each
% %%cluster
% for i=1:max(groundTruth);
%     cluster_groundtruth_members{i} = find(groundTruth==i);
% end
% 
% for dataType=1:size(dataCat,2);
%     for clusterIndex=1:C
%         cluster_spectral_members{dataType}{clusterIndex} = find(ind_group{dataType}==clusterIndex);
%     end
% end
% 
% %%%% Then, for each cluster figure out which is the closest groundTruth
% %%%% cluster
% clear clusterCorr temp;
% for dataType=1:size(dataCat,2);
%     for truthClusterIndex=1:C
%         for resultClusterIndex=1:C
%             temp(resultClusterIndex) = length(intersect(cluster_groundtruth_members{truthClusterIndex}, cluster_spectral_members{dataType}{resultClusterIndex}))/length(cluster_groundtruth_members{truthClusterIndex});
%         end
%         clusterCorr{dataType}(truthClusterIndex,:) = [truthClusterIndex find(temp==max(temp))];
%     end
% end
% 
% for dataType=1:size(dataCat,2);
%     for i=1:length(ind_group{dataType});
%         reorg_ind_group{dataType}(i,1) = find(clusterCorr{dataType}(:,2)==ind_group{dataType}(i));
%     end
% end
% 
% for dataType=1:size(dataCat,2)
%     acc_ind(dataType) = length(find(groundTruth==reorg_ind_group{dataType}))/length(groundTruth);
% end
% 
% 
% %%And we repeat the same for the SNF graph
% for clusterIndex=1:C
%     SNF_cluster_members{clusterIndex} = find(group==clusterIndex);
% end
% 
% for truthClusterIndex=1:C
%     for resultClusterIndex=1:C
%         temp(resultClusterIndex) = length(intersect(cluster_groundtruth_members{truthClusterIndex}, SNF_cluster_members{resultClusterIndex}))/length(cluster_groundtruth_members{truthClusterIndex});
%         %cluster_match_score{dataType}(truthClusterIndex)
%     end
%     SNFclusterCorr(truthClusterIndex,:) = [truthClusterIndex find(temp==max(temp))];
% end
% 
% clear reorg_group
% %%Rename the clusters to match the groundTruth cluster labels
% for i=1:length(group);
%     reorg_group(i,1) = find(SNFclusterCorr(:,2)==group(i));
% end
% 
% acc = length(find(groundTruth==reorg_group))/length(groundTruth);
% fprintf('The accuracies are:\nPath 1: %f\nPath 2: %f\nPath 3: %f\nPath 4: %f\nSNF: %f\n', acc_ind(1), acc_ind(2), acc_ind(3), acc_ind(4), acc);

%%%you can evaluate the goodness of the obtained clustering results by calculate Normalized mutual information (NMI): if NMI is close to 1, it indicates that the obtained clustering is very close to the "true" cluster information; if NMI is close to 0, it indicates the obtained clustering is not similar to the "true" cluster information.

[AR,RI,MI,HI]=RandIndex(group,groundTruth);
fprintf('Some cluster comparison metrics against groundTruth:\nAdjusted Rand Index: %f\nUnadjusted Rand Index: %f\nMirkin Index: %f\nHubert Index: %f',AR,RI,MI,HI);
fprintf('\n');

displayClusters(W,group);

SNFNMI = Cal_NMI(group, groundTruth)


%%%you can also find the concordance between each individual network and the fused network
ConcordanceMatrix = Concordance_Network_NMI({W,W_ind{1},W_ind{2},W_ind{3},W_ind{4}},C)


%%%Here we provide two ways to estimate the number of clusters. Note that,
%%%these two methods cannot guarantee the accuracy of esstimated number of
%%%clusters, but just to offer two insights about the datasets.

[K1, K2, K12,K22] = Estimate_Number_of_Clusters_given_graph(W, [2:round(length(groundTruth)/15)]);
fprintf('The best number of clusters according to eigengap is %d\n', K1);
fprintf('The best number of clusters according to rotation cost is %d\n', K2);
fprintf('\n');



%%%%We also provide an example using label propagation to predict the labels of new data points(see Demo2.m).


