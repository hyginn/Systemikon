
for pWithin_num = 1:size(A{1},1)
    for nSystems_num = 1:size(A{1},2)
        temp = A{1}{pWithin_num,nSystems_num};
        for graph_num = 2:size(A,2);
            temp = vertcat(temp,A{graph_num}{pWithin_num,nSystems_num})
        end
        PATHmean{pWithin_num,nSystems_num} = round(mean(temp));
        PATHdev{pWithin_num,nSystems_num} = round(std(temp));
    end
end

for gapMeasure = 1:4
    for pWithin_num = 1:size(PATHmean,1)
        for nSystems_num = 1:size(PATHmean,2)
            eigGapPATH{gapMeasure}(pWithin_num,nSystems_num) = PATHmean{pWithin_num,nSystems_num}(gapMeasure);
            eigGapPATHtDev{gapMeasure}(pWithin_num,nSystems_num) = PATHdev{pWithin_num,nSystems_num}(gapMeasure);
        end
    end
end


gapMeasure = 1;
hFig = figure(1);
set(hFig, 'Position', [0 0 800 900])
for gapMeasure = 1:4
    subaxis(4,2,gapMeasure*2-1,'MarginTop',0.05)
    accuracy = abs(eigGapPATH{gapMeasure}-repmat(nSystems_range,size(eigGapPATH{gapMeasure},1),1))./repmat(nSystems_range,size(eigGapPATH{gapMeasure},1),1);
    plot(pWithin_range,accuracy','-o','LineWidth',2);
    if gapMeasure == 1
        title('Mean of Individual Graphs');
    end
    switch gapMeasure
        case 1
            ylabel('1st EignGap');
        case 2
            ylabel('1st RotationCost');
        case 3
            ylabel('2nd EigenGap');
        case 4
            ylabel('2nd RotationCost');
    end
    ylim([0 1]);
end
%subplot(211);

%errorbar(repmat(pWithin_range,size(accuracy,2),1),accuracy',eigGapFirstDev',eigGapFirstDev');
%title('First EigenGap Accuracy of Mean of PATHs');

%ylabel('Number of Clusters Accuracy');
%text(0.02,0.98,'a','Units', 'Normalized', 'VerticalAlignment', 'Top')

%legend(num2str(nSystems_range(1)),num2str(nSystems_range(2)),num2str(nSystems_range(3)),num2str(nSystems_range(4)))
temp = [];
for i=1:length(nSystems_range)
    temp{i} = strcat(num2str(nSystems_range(i)),' Systems');
end
legend(temp);

for gapMeasure = 1:4
    for pWithin_num = 1:size(A{5},1)
        for nSystems_num = 1:size(A{5},2)
            eigGapSNF{gapMeasure}(pWithin_num,nSystems_num) = A{5}{pWithin_num,nSystems_num}(gapMeasure);
        end
        
    end
end



%accuracy = abs(eigGapSNF-repmat(nSystems_range,size(eigGapSNF,1),1))./repmat(nSystems_range,size(eigGapSNF,1),1);
for gapMeasure = 1:4
    subaxis(4,2,gapMeasure*2,'MarginTop',0.05)
    accuracy = abs(eigGapSNF{gapMeasure}-repmat(nSystems_range,size(eigGapSNF{gapMeasure},1),1))./repmat(nSystems_range,size(eigGapSNF{gapMeasure},1),1);
    plot(pWithin_range,accuracy','-o','LineWidth',2);
    if gapMeasure == 1
        title('SNF');
    end
    ylim([0 1]);
end

suplabel('Error of various cluster number determination methods','y');
suplabel('Probability of Connection Between Nodes of Same System','x');

% subplot(212);
% plot(pWithin_range,accuracy','-o');
% title('First EigenGap Accuracy of SNF');
% xlabel('pWithin');
% ylabel('Number of Clusters Accuracy');
% temp = [];
% for i=1:length(nSystems_range)
%     temp{i} = strcat(num2str(nSystems_range(i)),' Systems');
% end
% legend(temp)

%A{graph_num}{pWithin_num,nSystems_num}
