function [nextGrid,duration,bits,offset,remainingPRBs] = nodeWantsToDoSomething(LastGrids,duration,bits,offset, remainingPRBs)

for AP=1:length(duration)
    
    % Check if node is in the middle of activity
    [working, nextGrid(AP,:,:), remainingPRBs(AP), duration(AP)] = updateActivity(LastGrids(AP,:,:), remainingPRBs(AP), duration(AP));
    if working
        continue;
    end
    
    % If not see if AP has node that wants to transmit
    %transmit = randn>0.5;
    transmit = poissrnd(0.5);
    
    if transmit
        % Pick task
        task = randi([0 1],1,1);
        [remainingPRBs(AP), bits(AP), nextGrid(AP,:,:), duration(AP)] = chooseTaskDurationAndBits(task,'QPSK', 948/1024, LastGrids(AP,:,:));
    end
    
    
end

end

function [working, nextGrid, PRBsRemaining, duration] = updateActivity(grid, PRBsRemaining, duration)


global channelBandwidth;

% Am I transmitting in this upcoming frame
if duration == 0
    working = 0;
    % reset grid
    nextGrid = grid;
    nextGrid(1,:,:) = generateGrid(channelBandwidth);
else
    working = 1;
    % Apply workload to grid
    %maxAvailablePerFrame = size(grid,2)*size(grid,3);
    maxAvailablePerFrame = 1*size(grid,3);
    
    if PRBsRemaining > maxAvailablePerFrame
        PRBsRemaining = PRBsRemaining - maxAvailablePerFrame;
        nextGrid = applyResourcesToGrid(grid, maxAvailablePerFrame);
    else
        if PRBsRemaining == 0 % This is a stream type of traffic, like VOIP not a raw download
          [~, ~, nextGrid] = chooseTaskDurationAndBits(0,'QPSK', 948/1024, grid);
        else
            nextGrid = applyResourcesToGrid(grid, PRBsRemaining);
        end
        PRBsRemaining = 0;
    end
    
    duration = duration - 1;
end


end

function [remainingPRBs, bits, nextGrid, Duration] = chooseTaskDurationAndBits(task, modulation, coderate,grid)

switch task
    case 0 % Voice
        Duration = 30; %Frames to last over
        bits = 300;
        PRBs = determineNeededPRBs( bits, modulation, coderate);
        nextGrid = applyResourcesToGrid(grid, PRBs);
        remainingPRBs = 0; % not important here
        
    case 1 % Website Visit
        bits = 10e3;
        PRBs = determineNeededPRBs( bits, modulation, coderate);
        %maxAvailablePerFrame = size(grid,2)*size(grid,3);
        maxAvailablePerFrame = 1*size(grid,3);
        
        Duration = ceil(PRBs/maxAvailablePerFrame); %Frames to last over
        
        if PRBs > maxAvailablePerFrame
            remainingPRBs = PRBs - maxAvailablePerFrame;
            nextGrid = applyResourcesToGrid(grid, maxAvailablePerFrame);
        else
            remainingPRBs = 0;
            nextGrid = applyResourcesToGrid(grid, PRBs);
        end
        
end
end

function nextGrid = applyResourcesToGrid(grid, PRBsToApply)

global channelBandwidth;

% Set starting PRB in frame for continous blocks
offset = randi([1 (20-PRBsToApply+1)],1,1);

% Place PRB
frequency = 2;
nextGrid = grid;
nextGrid(1,:,:) = generateGrid(channelBandwidth);
nextGrid(1,frequency,offset:offset+PRBsToApply-1) = 100;

end



