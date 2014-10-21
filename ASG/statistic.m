function [performance, stats] = statistic(Attributes, TargetStats)        
%fitness function
    TargetMean = TargetStats(5, :);
    TargetStd = TargetStats(7, :);
    transform = transformAttributes(Attributes, TargetMean, TargetStd);
    [x, M, S, st] = generateStatistics(transform);
    stats = [x ; M ; S ; st];
    [performance, stats] = compare(stats, TargetStats);
end

function[x,M,S,st]=generateStatistics(Attributes)   %calculate the statistics of the synthetic network                           
x = quantile(Attributes,[0.25 0.50 0.75 0.975],1);   
M = mean(Attributes,1);    %mean for each coloum
S = skewness(Attributes,0,1);  
st = std(Attributes,0,1) ;     
end

function[corr, stats]=compare(stats, targetStats)            
corr = mean(mean(corrcoef(targetStats, stats)));
end

