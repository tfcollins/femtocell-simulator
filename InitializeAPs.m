function AccessPoints = InitializeAPs(numAPs,apPositions)


% Setup all access point instances
AccessPoints = cell(numAPs,1);
for ap = 1:numAPs    
    AccessPoints{ap} = AccessPoint(ap);
    AccessPoints{ap}.attachedNodes = 1;
    
    possibleChannelBandwidths = [1.4, 3, 5, 10, 15, 20]'*1e6;
    %key = randi([1 length(possibleChannelBandwidths)]);
    key = 1;
    AccessPoints{ap}.apChannelBandwidth = possibleChannelBandwidths(key);
    AccessPoints{ap}.resourceGrid = generateGrid(AccessPoints{ap}.apChannelBandwidth);
    AccessPoints{ap}.apPosition = [apPositions(ap,2),apPositions(ap,1)];   
end


end