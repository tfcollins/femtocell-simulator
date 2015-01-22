function viewPRBUsage(channelUsageGrid, figNum)

figure(figNum);
bar3(channelUsageGrid);
xlabel('Time (PRB)');
ylabel('Frequency (PRB)');
zlabel('AP''s Allocated');

end