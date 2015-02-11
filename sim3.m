%sim3
% The goal of this simulation is to measure the interference at one node

% Arrange node around one another
gridSize = [100, 100];
numAPs = 100;
arrangement = 'uniform';
apPositions = arrangeAPs(gridSize, arrangement, numAPs);
observerPosition = [50, 50];
% Setup all AP instances
AccessPoints = InitializeAPs(numAPs,apPositions);
% View positions
viewPositions(gridSize, AccessPoints, 1, observerPosition);
% Pathloss Info
linkInfo = getPathlossPairs([apPositions;observerPosition]);

% Can we formulate a bound or mean interference level for each Resource
% block


frames = 100;
for frame = 1:frames
    
    for ap = 1:numAPs
        AccessPoints{ap}.AllpathlossPairs = linkInfo;
        AccessPoints{ap}.AllAPs = AccessPoints;
        AccessPoints{ap}.step(1);
        %AccessPoints{ap}.viewGrid
        %pause(4);
    end
    observer = numAPs+1;
    [comboGrid, channelUsageGrid] = combinedGrids(AccessPoints,linkInfo,observer);
    viewGrid(comboGrid, 2);
    viewPRBUsage(channelUsageGrid,3);
    
    pause(1);
end