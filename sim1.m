% The purpose of this simulation is to demonstrate resource block
% reservation behavior when multiple femto-cells exists within the same
% channel or band.

% Variables
% Distance from nodes
% Number of nodes
% Resource requirements per application

% All nodes compete over a resource grid/map.  Everytime a resource is
% allocated it appears as energy to the other AP's in the area on their own
% access grid.  The energy level per resource block depends on the distance
% that AP is from the others and their pathloss profile.

close all; clear all;

%% Setup
numAPs = 3;
gridSize =[100,100];
apPositions = [10,10; 10,90; 90,10; 45,45]; % last node is energy level reading node
viewPositions(gridSize, apPositions, figure(1));
global channelBandwidth;
channelBandwidth = 1.4e6;

% Get pathloss pairs
pathloss = getPathlossPairs(apPositions);

% Resource map initialize
sampleGrid = generateGrid(channelBandwidth);
nextGrids = zeros(numAPs,size(sampleGrid,1),size(sampleGrid,2));
for AP = 1:numAPs
    nextGrids(AP,:,:) = generateGrid(channelBandwidth);
end
gridID = figure(1);
%viewGrid(nextGrid, gridID);

frames = 1000;

% Preallocate
[duration,bits,offset,remainingPRBs]=deal(zeros(numAPs,1));

%% Simulate
for frame = 1:frames
% Phase one, APs randomly select if they have an attached node that wants
% to allocate resources

% Phase two, allocated nodes randomly select an activity and duration for
% such an activity

% Phase three, AP allocate resouces accordingly to their allocation maps
% and available channels or weight channels
LastGrids = nextGrids;
[nextGrids,duration,bits,offset,remainingPRBs] = nodeWantsToDoSomething(LastGrids,duration,bits,offset, remainingPRBs);

% Output resource map view
for AP = 1:numAPs
    figure(2)
    subplot(numAPs+1,1,AP);
    viewGrid(squeeze(nextGrids(AP,:,:)), figure(2));
end

% Get energy at viewer node
grid = combinedGrids(nextGrids,pathloss);
figure(2)
subplot(numAPs+1,1,AP+1);
viewGrid(grid, figure(2));

pause(0.5);
% repeat operation
end




