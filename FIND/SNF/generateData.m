function [ rawData, groundTruth ] = generateData( nGenes_num, nSystems_num, pWithin_num, makeGPMmatrixLocation )
%generateData Generate synthetic data for use in SNF Find
%   This functions requires an R server installed to generate data using
%   BS's code.
       
        %Prepare parameter for calling the R server
        nSystems = num2str(nSystems_num);
        pWithin = num2str(pWithin_num);
        nGenes = num2str(nGenes_num);
        Rinput = strcat('a <- makeGPMmatrix(nGenes=',nGenes,',','nSystems=',nSystems,',','pWithin=',pWithin,')');
        
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
        
%         %rawData matrix should have the following form
%         %geneA geneB iRefScore GEOScore GOScore pathWScore
%         geneA = rawData(:,1);
%         geneB = rawData(:,2);
%         iRef = rawData(:,3);
%         GEO = rawData(:,4);
%         GO = rawData(:,5);
%         pathW = rawData(:,6);

end

