function grid = generateGrid(channelBandwidth)

% This will create a resource grid for 1 radio frame or 10ms

% Resource element == 1 Subcarrier == 1 OFDM symbol duration == 0.0714 ms
% 1 Resource block == 180Khz for 0.5ms == 7 OFDM Symbols == 12 Subcarriers == 1 slot
% Subframe == TTI (Transmission time interval)== 1ms duration == 2 resource blocks duration
% Radio frame == 10ms == 10 subframes == 20 resource blocks duration

% Transmission Bandwidth: bandwidth of instanteous transmission from UE or
% BS, measured in resource block units


possibleChannelBandwidths = [1.4, 3, 5, 10, 15, 20]'*1e6;
transmittBandwidths = [1.08, 2.7,4.5,9,13.5,18]'*1e6;

% Select transmittion bandwidth
txBW = transmittBandwidths(possibleChannelBandwidths==channelBandwidth);

% Possible resource blocks available
bandwidthOfPRB = 180e3;
numPRB = txBW/bandwidthOfPRB;

% create empty grid
PRBperSubframe = 2;
SubframesPerRadioFrame = 10;
PRBperFrame = PRBperSubframe* SubframesPerRadioFrame;

noiseFloor = 0;
grid = ones(numPRB,PRBperFrame)*-noiseFloor;



end