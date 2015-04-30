%% Script to try multiple pWithin values from Prof. Steipe's code and output the NMI and estimated number of clusters
% Note, before this is executed, the system specific paths and R server
% must be installed. openR must be issued to open the R server
% This code generates a plot to compare NMI and cluster number as a
% function of the pWithin value

clear
clc

% First declare parameters
nSystems_num = 32; %The number of systems for synthetic data generation
nGenes_str = num2str(2000); %Number of genes for synthetic data generation
pWithinValues = [0.001 0.005 0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.4 0.8] %The values of pWithin to iterate over
makeGPMmatrixLocation = 'source("C:/Users/Naveen/Documents/makeGPMmatrix.R")'; %Path for makeGPMmatrix

count=0;
for i = pWithinValues
    i
    count=count+1;
    
    %Prepare parameter for calling the R server
    nSystems = num2str(nSystems_num);
    pWithin = num2str(i);
    Rinput = strcat('a <- makeGPMmatrix(nGenes=',nGenes_str,',','nSystems=',nSystems,',','pWithin=',pWithin,')');

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

    %Store the data in the following matrix
    [NMI(count) suggestedClusterNumber(count)]=SNFpermutation(rawData, groundTruth, nSystems_num);
end
figure;
subplot(211)
plot([0.001 0.005 0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.4 0.8],abs(NMI));
xlabel('pWithin');
ylabel('Normalized Mutual Information');
subplot(212)
plot([0.001 0.005 0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.4 0.8],suggestedClusterNumber)
xlabel('pWithin');
ylabel('Suggested Number of Clusters');