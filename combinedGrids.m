function [combinedGrid, channelUsageGrid] = combinedGrids(AccessPoints,pathlossPairs,observer)

aps = length(AccessPoints);

%maxBandwidth = 20e6;
% Determine Large bandwidth of all APs (Makes view easier)
maxBandwidth = 0;
for k=1:aps
    bw = AccessPoints{k}.apChannelBandwidth;
    if bw > maxBandwidth
        maxBandwidth = bw;
    end
end

combinedGrid = generateGrid(maxBandwidth);

channelUsageGrid = combinedGrid;

% Antenna Gains
Femto_ant = 5; % dBi Omni
UE_ant = 1.04;

% Transmission Power
Femto_Tx_Power = 10000; % dBm (SHOULD BE 20)


for AP = 1:aps

    if observer==AP % Skip self
        continue
    end
    
    grid = AccessPoints{AP}.resourceGrid;
    
    % Expand to fullsize grid (if usings smaller bandwidth it will be
    % smaller)
    tmpGrid = generateGrid(maxBandwidth);
    tmpGrid(1:size(grid,1),1:size(grid,2)) = grid;
    
    % Calculate pathlosses
    PL = pathlossPairs(observer).Pathloss(AP) + log(lognrnd(0,pathlossPairs(observer).sigma(AP)));
    Rx_Power = Femto_Tx_Power + Femto_ant - PL;
    
    % Apply to received grid at observation node
    marker = 100;
    combinedGrid  = combinedGrid + tmpGrid.*Rx_Power/marker;

    channelUsageGrid = channelUsageGrid + (tmpGrid~=0);
    
end
    


end