function [ W_ind, groundTruth ] = genNoisyData( noiseType, noiseValue, nGenes_num, nSystems_num, pWithin_num, makeGPMmatrixLocation )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
        % For pWithin, we need to generate the data later, with the value
        % of pWithin required
        if ~strcmp(noiseType,'pWithinNoise')
            [rawData groundTruth] = generateData(nGenes_num, nSystems_num, pWithin_num, makeGPMmatrixLocation);
            [W_ind] = generateAdjacencyMatrix(rawData);
        end
        
        %% Generate noise
        for graphNum = 1:length(W_ind)
            switch noiseType
                case 'sigma'
                    noise = random('Normal',0,noiseValue,size(W_ind{graphNum},1),size(W_ind{graphNum},2));
                    %noise = tril(noise);
                    %noise = noise+noise';
                    %noise(logical(eye(size(noise)))) = 0;
                    W_ind{graphNum} = abs(W_ind{graphNum} + noise);
                    W_ind{graphNum}(find(W_ind{graphNum}>1)) = 1;
                case 'gamma'
                    noise = random('gam',0.2,noiseValue,size(W_ind{graphNum},1),size(W_ind{graphNum},2));
                    %noise = tril(noise);
                    %noise = noise+noise';
                    %noise(logical(eye(size(noise)))) = 0;
                    W_ind{graphNum} = W_ind{graphNum} + noise;
                    W_ind{graphNum} = abs(W_ind{graphNum} + noise);
                    W_ind{graphNum}(find(W_ind{graphNum}>1)) = 1;
                case 'dataCorruption'
                    %noise = rand(size(W_ind{graphNum},1),size(W_ind{graphNum},2));
                    for i=1:size(W_ind{graphNum},1)
                        for j=1:size(W_ind{graphNum},2)
                            if rand(1)<noiseValue
                                W_ind{graphNum}(i,j) = 0;
                            end
                        end
                    end
                    
                    %Ensure matrix is symmetrical by mirroring lower
                    %triangular of matrix and setting diagonal to zero
                    W_ind{graphNum} = tril(W_ind{graphNum});
                    W_ind{graphNum} = W_ind{graphNum}+W_ind{graphNum}';
                    W_ind{graphNum}(logical(eye(size(W_ind{graphNum})))) = 0;
            end
        end
        
        
        % Generate the adjacency matrices once the pWithin value is
        if strcmp(noiseType,'pWithinNoise')
            pWithin_num = 1-noiseValue;
            [rawData groundTruth] = generateData(nGenes_num, nSystems_num, pWithin_num, makeGPMmatrixLocation);
            [W_ind] = generateAdjacencyMatrix(rawData);
        end

end

