function [TargetStats] = loadStats(targetStatsFilename)         %load the statistics
    TargetStats = load(targetStatsFilename)';
end