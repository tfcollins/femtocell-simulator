% sim2
close all;
%clear all;

aps = 100;
spacing = 10; % meters
% Create positions
apPositions = [repmat((1:aps/spacing).',spacing,1),...
       reshape(repmat((1:aps/spacing).',1,spacing)',aps,1)].*spacing;
observerPosition = [55, 55];

% Setup all access point instances
AccessPoints = cell(aps,1);
for ap = 1:aps    
    AccessPoints{ap} = AccessPoint(ap);
    AccessPoints{ap}.attachedNodes = 1;
    
    possibleChannelBandwidths = [1.4, 3, 5, 10, 15, 20]'*1e6;
    %key = randi([1 length(possibleChannelBandwidths)]);
    key = 1;
    AccessPoints{ap}.apChannelBandwidth = possibleChannelBandwidths(key);
    AccessPoints{ap}.resourceGrid = generateGrid(AccessPoints{ap}.apChannelBandwidth);
    AccessPoints{ap}.apPosition = [apPositions(ap,2),apPositions(ap,1)];   
end

% View node arrangement
viewPositions( [spacing*10,spacing*10], AccessPoints, 1, observerPosition)
pause(4);

% Pathloss Info
linkInfo = getPathlossPairs([apPositions;observerPosition]);


frames = 100;
for frame = 1:frames
    
    for ap = 1:aps
        AccessPoints{ap}.AllpathlossPairs = linkInfo;
        AccessPoints{ap}.AllAPs = AccessPoints;
        AccessPoints{ap}.step(1);
        %AccessPoints{ap}.viewGrid
        %pause(4);
    end
    observer = aps+1;
    [comboGrid, channelUsageGrid] = combinedGrids(AccessPoints,linkInfo,observer);
    viewGrid(comboGrid, 2);
    viewPRBUsage(channelUsageGrid,3);
    
    pause(1);
end