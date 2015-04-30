%% Script to generate multiple types of noise from Prof. Steipe's code and output the NMI and estimated number of clusters
% Note, before this is executed, the system specific paths and R server
% must be installed. openR must be issued to open the R server
% This code generates a plot to compare NMI and cluster number as a
% function of the different types of noise

%clear
%clc

%% Parameters
nSystems_range =[ 16 32 64 128] %The number of systems for synthetic data generation
nGenes_num = 2000; %Number of genes for synthetic data generation
nSystems_num = 32; %May not be needed
pWithin_num = 0.6; %Default pWithin value for other types of noise
noiseTypes = {'sigma'; 'gamma'; 'dataCorruption'; 'pWithinNoise'}; %Types of noise

% SNF HyperParameters (not needed)
K = 20;%number of neighbors, usually (10~30)
alpha = 0.5; %hyperparameter, usually (0.3~0.8)
T = 20; %Number of Iterations, usually (10~20)

% R Server parameter
makeGPMmatrixLocation = 'source("C:/Users/Naveen/Documents/makeGPMmatrix.R")'; %Path for makeGPMmatrix

%% Loop for each type of noise
for x = 1:length(noiseTypes)
    %% Set the range for each type of noise
    noiseType = noiseTypes{x}
    switch noiseType
        case 'sigma'
            noiseRange = [0 0.1 0.2 0.3 0.35 0.4 0.45 0.5 0.8]
        case 'gamma'
            noiseRange = [0 0.1 0.2 0.3 0.5 0.8 1 1.25 1.5 2]%0:0.1:1
        case 'dataCorruption'
            noiseRange = [0 0.1 0.2 0.3 0.4 0.5 0.6]
        case 'pWithinNoise'
            noiseRange = [0 0.1 0.2 0.5 0.6 0.7 0.8 0.9 1]
    end
    
    count=0;
    
    %% Generate noise, calculate NMI and cluster numbers for each graph and the SNF graph
    for y = 1:length(noiseRange)
        
        noiseValue = noiseRange(y);
        fprintf('Noise = %f\n',noiseValue);
        count = count + 1;
        

        [ W_ind, groundTruth ] = genNoisyData( noiseType, noiseValue, nGenes_num, nSystems_num, pWithin_num, makeGPMmatrixLocation );
        
        
        % Save data to correct variable
        switch noiseType
            case 'sigma'
                [sigNoise{1}(:,y) sigNoise{2}(:,y)] = SNFpermutation2(W_ind, groundTruth, nSystems_num);
            case 'gamma'
                [gamNoise{1}(:,y) gamNoise{2}(:,y)] = SNFpermutation2(W_ind, groundTruth, nSystems_num);
            case 'dataCorruption'
                [dataCorruption{1}(:,y) dataCorruption{2}(:,y)] = SNFpermutation2(W_ind, groundTruth, nSystems_num);
            case 'pWithinNoise'
                [pWithinNoise{1}(:,y) pWithinNoise{2}(:,y)] = SNFpermutation2(W_ind, groundTruth, nSystems_num);
        end
        fprintf('\n');
    end
    
    %% Plot the data
    switch noiseType
        case 'sigma'
            subplot(421);
            plot(noiseRange,sigNoise{1},'-o','LineWidth',2);
            ylabel('NMI');
            xlabel('Gaussian Noise Variance, \sigma');
            
            subplot(422);
            plot(noiseRange,sigNoise{2},'-o','LineWidth',2);
            ylabel('Suggested cluster number');
            xlabel('Gaussian Noise Variance, \sigma');
        case 'gamma'
            subplot(423);
            plot(noiseRange,gamNoise{1},'-o','LineWidth',2);
            ylabel('NMI');
            xlabel('Gamma Noise Scale Parameter, \alpha');
            
            subplot(424);
            plot(noiseRange,gamNoise{2},'-o','LineWidth',2);
            ylabel('Suggested cluster number');
            xlabel('Gamma Noise Scale Parameter, \alpha');
        case 'dataCorruption'
            subplot(425);
            plot(noiseRange,dataCorruption{1},'-o','LineWidth',2);
            ylabel('NMI');
            xlabel('% Data Corrupted');
            
            subplot(426);
            plot(noiseRange,dataCorruption{2},'-o','LineWidth',2);
            ylabel('Suggested cluster number');
            xlabel('% Data Corrupted');
        case 'pWithinNoise'
            subplot(427);
            plot(noiseRange,pWithinNoise{1},'-o','LineWidth',2);
            xlabel('pWithin Noise');
            
            ylabel('NMI');
            subplot(428);
            plot(noiseRange,pWithinNoise{2},'-o','LineWidth',2);
            ylabel('Suggested cluster number');
            xlabel('pWithin Noise');
    end
end
subplot(422);
legend('Graph 1','Graph 2','Graph 3','Graph 4','SNF');
