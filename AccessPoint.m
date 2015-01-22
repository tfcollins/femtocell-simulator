classdef AccessPoint < matlab.System

    % ToDo:
    % 1. PRB placement smartly or ok-smartly
    % 2. Enviromental variablity (Sensing)+++
    % 3. Fixed offset in time for voice calls
    % 4. Graph showing PRBs in use, not power levels (Easier to look at)+++
        % Possible histogram
    % 5. Update of coderate and modulation based on enviroment
    % 6. Need to consider spread trade-off when replacing blocks
        
    % Bugs:
    % 1. Some allocation problem causing crashes
    
    
    % Assumption:
    % 1. All channels are stack in the same band
    % 2. if channels are smaller they occupy same spectrum location
    % 3. Nodes cannot end a task and start a new one in the same frame
    
    properties
        attachedNodes = 0;
        nodeTasks
        resourceGrid
        bitQueueSize
        taskDuration
        apChannelBandwidth = 1.4e6;
        apID = 1;
        figID = 1;
        activeNodes
        nodeCodeRates
        nodeModulation
        apPosition
        maxAvailablePRBs = 0;
        nodePRMmap
        nodeInitializationFlag
        lastPRBsLinearAllocated
        availablePRBs
        
        AllpathlossPairs
        AllAPs
        
    end
    
    methods
        function obj = AccessPoint(ID)
            obj.apID = ID;
        end
    end
    
    methods (Access = protected)
        function setupImpl(obj,~)
            
            % Preinitialize arrays and matrices
            [obj.bitQueueSize, obj.taskDuration, obj.nodeTasks, obj.activeNodes, obj.nodeCodeRates, obj.nodeInitializationFlag]...
                = deal(zeros(obj.attachedNodes,1));
            
            obj.resourceGrid = generateGrid(obj.apChannelBandwidth);
            obj.nodePRMmap = zeros(obj.attachedNodes,size(obj.resourceGrid,1),size(obj.resourceGrid,2));
            
            obj.nodeModulation = cell(obj.attachedNodes,1);
            obj.lastPRBsLinearAllocated = cell(obj.attachedNodes,1);
        end
        
        function stepImpl(obj,nodeID)

            % Clear resource grid
            obj.resourceGrid = generateGrid(obj.apChannelBandwidth);
            
            % Sense world
            obj.availablePRBs = obj.EvaluateNextPRBs();
            
            % Max resources usable
            obj.maxAvailablePRBs = numel(obj.availablePRBs);
            
            % Give precedent to active nodes
            nodes = 1:obj.attachedNodes;
            active = nodes(obj.activeNodes>0);
            notActive = nodes((obj.activeNodes>0)==false);
            nodes = [active,notActive];
            
            % Cycle through all nodes in network
            for node = 1:obj.attachedNodes
                nodeID = nodes(node);
                if obj.activeNodes(nodeID)% If AP has working nodes, continue with tasks
                    disp('Updating Task');
                    obj.updateCurrentTask(nodeID);
                else
                    % Should I do something?
                    transmit = poissrnd(0.5);
                    if transmit
                        disp('Creating New Task');
                        obj.nodeInitializationFlag(nodeID) = true;% Starting intialization
                        obj.activeNodes(nodeID) = true;
                        obj.createTask(nodeID);
                        obj.nodeInitializationFlag(nodeID) = false;% Completed intialization
                    end
                end
            end
        end
        
        function createTask(obj,nodeID)
            
            % Update coderate and modulation
            obj.determineMCS(nodeID);
            
            % Pick task
            obj.nodeTasks(nodeID) = randi([0 1],1,1);
            switch obj.nodeTasks(nodeID)
                case 0 % Voice
                    disp('Making a call');
                    callDuration = randi([5 30]);
                    obj.taskDuration(nodeID) = callDuration; %Radio Frames to last over
                    obj.bitQueueSize(nodeID) = 300;
                    
                case 1 % Website Visit
                    disp('Visiting a website');
                    obj.taskDuration(nodeID) = -1; %Not used for task
                    obj.bitQueueSize(nodeID) = 10e3;

                otherwise
                    error('Something broke');
                    
            end
            disp(['Queue Size: ',num2str(obj.bitQueueSize(nodeID))]);
            
            % Update resource grid
            obj.applyResourcesToGrid(nodeID)
            
        end
        
        function updateCurrentTask(obj,nodeID)
            
            % Update active nodes
            if obj.taskDuration(nodeID) == 0 % Deactive finished streaming nodes
                obj.activeNodes(nodeID) = false;
                return;
                
            elseif (obj.taskDuration(nodeID)==-1) && (obj.bitQueueSize(nodeID) == 0)% Deactive finished non-streaming nodes
                obj.activeNodes(nodeID) = false;
                
            end
            
            % Update coderate and modulation based on enviroment
            obj.determineMCS(nodeID);
            
            % If we have a streaming task add necessary bits to queue
            if obj.taskDuration > 0
                obj.updateQueue(nodeID) % Updates duration as well
            end
            disp(['Queue Size: ',num2str(obj.bitQueueSize(nodeID))]);
            
            % Update resource grid
            if obj.bitQueueSize(nodeID)>0
                obj.applyResourcesToGrid(nodeID) % removes resources from queues
            end
        end
        
        % For streaming tasks add new data to queue
        function updateQueue(obj,nodeID) 
            
            switch obj.nodeTasks(nodeID)
                case 0 % Voice
                    obj.taskDuration(nodeID) = obj.taskDuration(nodeID) - 1;
                    obj.bitQueueSize(nodeID) = 300;
                    
                otherwise
                    error('Something Broke');
            end
            
        end
        
        
        function applyResourcesToGrid(obj,nodeID)
            
            % Get current channel info for coderate and modulation
            %fixed for now
            bits = obj.bitQueueSize(nodeID);
            
            % Convert bits to resource blocks and calculate how many we can
            % put into this transmission
            PRBs = obj.determineNeededPRBs( bits, nodeID ); % bit queue updated in call
            
            % Update remaining resources for other users
            obj.maxAvailablePRBs = obj.maxAvailablePRBs - PRBs;
            
            % Sense around what are the best channels to select
            %DO LATER
            % Sort PRBs by best avaiable
            %DO LATER
            
            
            
            % Select PRBs of remaining
            locationsOfSelectedPRBs = obj.selectBestPRBs(PRBs,nodeID);
            
            % Add resouces to current grid
            %frequency = randi([1 size(obj.resourceGrid,1)],1,1);
            %offset = randi([1 (20-PRBs+1)],1,1);
            %obj.resourceGrid(frequency,offset:offset+PRBs-1) = 100;
            for k=1:size(locationsOfSelectedPRBs,1)
                    obj.resourceGrid(...
                        locationsOfSelectedPRBs(k,1),...
                        locationsOfSelectedPRBs(k,2)) = 100;
                    obj.nodePRMmap(nodeID,...
                        locationsOfSelectedPRBs(k,1),...
                        locationsOfSelectedPRBs(k,2)) = 1;
            end
            % Keep track of what user has what
            %obj.nodePRMmap(nodeID,frequency,offset:offset+PRBs-1) = 1;
            %obj.nodePRMmap(locationsOfSelectedPRBs) = 1;
            
        end
        
        function availablePRBs = EvaluateNextPRBs(obj)
        
            combinedGrid = obj.SenseEnvirorment();
            
            % Select part of grid we have access to (as in our bandwidth)
            gridDims = size(obj.resourceGrid);
            myGrid = combinedGrid(1:gridDims(1),1:gridDims(2));
            
            % Convert to linear indexing 
            %gridIndex = reshape(1:numel(obj.resourceGrid),gridDims(1),gridDims(2));
            
            combinedGridLin = reshape(myGrid,gridDims(1)*gridDims(2),1);
            
            [powerLevels, availablePRBs] = sort(combinedGridLin);
            
            % Remove values beyond theshold
            threshold = mean(powerLevels(1:mean(length(combinedGridLin)/4)));
            availablePRBs(powerLevels>(threshold+1)) = [];
            
        end
        
        function indexs = selectBestPRBs(obj,numPRBs, nodeID)
           
            % These are the resources that have not been taken
            indexs = obj.availablePRBs;
            
            % Select lowest possibly allocated channels
            %selectedIndexs = indexs(1:numPRBs);
            selectedIndexs = obj.Scheduler(indexs, numPRBs, nodeID);
            
            % Update resources taken
            for resource = 1:length(selectedIndexs)
                obj.availablePRBs(obj.availablePRBs==selectedIndexs(resource))=[];
            end
            
            % Now Get matrix index from these linear ones
            gridDims = size(obj.resourceGrid);
            row = mod(selectedIndexs+gridDims(1)-1,gridDims(1))+1;
            column = floor((selectedIndexs+gridDims(1)-1)/gridDims(1));
            indexs = [row,column];
            
        end
        
        function selectedBlocks = Scheduler(obj, blocks, numPRBs, nodeID)
        
            % Scheduling should be based on tasks
            switch obj.nodeTasks(nodeID)
           
                case 0 % Voice call
                    % When was the last schedule PRB, we should try to be
                    % near that in time
                    
                    % Is this PRB initial placement?
                    if obj.nodeInitializationFlag(nodeID)
                        % Since we are starting a new call, we can select a
                        % PRB anywhere, but we will try to place them in
                        % continous blocks first
                        for block = 1:length(blocks)-numPRBs+1
                            desiredBlocks = blocks(block):blocks(block)+numPRBs-1;
                            availableBlocks = blocks(block:block+numPRBs-1).';
                            
                            if sum(desiredBlocks - availableBlocks) == 0
                                selectedBlocks = availableBlocks;
                                obj.lastPRBsLinearAllocated{nodeID} = selectedBlocks; % Update history for later
                                return;
                            end
                        end
                        
                        % No continous blocks can be selected, select
                        % minimally spread blocks
                        if numel(blocks)==numPRBs
                            selectedBlocks = blocks;
                            obj.lastPRBsLinearAllocated{nodeID} = selectedBlocks; % Update history for later
                        else
                            spreads = zeros(floor(numel(blocks)/numPRBs),1);
                            for block=1:length(blocks)-numPRBs+1
                                if (block+numPRBs-1)>numel(blocks)
                                    x=1;%BUGGGGGGGGGGGGGGGGGG????
                                end
                                loc =  blocks(block:block+numPRBs-1);
                                spreads(block) = loc(end:-1:2) - loc(end-1:-1:1);
                            end
                            [~,minSpread] = min(spreads);
                            selectedBlocks = blocks(minSpread:minSpread+numPRBs-1);
                            obj.lastPRBsLinearAllocated{nodeID} = selectedBlocks; % Update history for later
                            return
                        end
                        
                    else% Not initial placement of blocks
                        
                        % We should try to pick blocks that are close to
                        % the previously placed ones
                        previousLocations = obj.lastPRBsLinearAllocated{nodeID};
                        % Are those still available and do we have enough blocks?
                        matchingBlocks = 0;
                        for k=1:length(blocks)
                            matchingBlocks = matchingBlocks + sum(previousLocations==blocks(k));
                        end
                        if (matchingBlocks >= numPRBs)
                            selectedBlocks = previousLocations(1:numPRBs);
                            obj.lastPRBsLinearAllocated{nodeID} = selectedBlocks; % Update history for later
                            return;
                        else % We have to pick something else, hopefully close, again with small spread
                            
                            if numel(blocks)==numPRBs
                                selectedBlocks = blocks;
                                obj.lastPRBsLinearAllocated{nodeID} = selectedBlocks; % Update history for later
                            else
                                spreads = zeros(floor(numel(blocks)/numPRBs),1);
                                meanDistanceFromOriginalBlock = zeros(size(spreads));
                                for block=1:length(blocks)-numPRBs+1
                                    loc =  blocks(block:block+numPRBs-1);
                                    meanDistanceFromOriginalBlock(block) = abs(mean((loc)) - mean((previousLocations)));
                                    spreads(block) = loc(end:-1:2) - loc(end-1:-1:1);
                                end
                                % pick blocks group with the smallest distance
                                % from original blocks
                                %FIX Need to consider spread trade-off
                                [~,minDist] = min(meanDistanceFromOriginalBlock);
                                selectedBlocks = blocks(minDist:minDist+numPRBs-1);
                                obj.lastPRBsLinearAllocated{nodeID} = selectedBlocks; % Update history for later
                                return
                            end
                            
                        end
                    end
                    
                case 1 % Web page access
                    % Place blocks in best possible positions
                    selectedBlocks = blocks(1:numPRBs);
                    obj.lastPRBsLinearAllocated{nodeID} = selectedBlocks; % (Not important for application)
                    return
                    
                otherwise
                    error('Something Broke');
            end
            
        end
        
        function combinedGrid = SenseEnvirorment(obj)
            % Get combined energy from all 
            observer = obj.apID;
            combinedGrid = combinedGrids(obj.AllAPs,obj.AllpathlossPairs,observer);

        end
        
        % Calculate how many of the available blocks will be used
        function PRBallocated = determineNeededPRBs( obj, bits, nodeID )
            
            
            switch obj.nodeModulation{nodeID}
                case 'QPSK'
                    bitsPerSymbol = 2;
                case 'QAM16'
                    bitsPerSymbol = 4;
                case 'QAM64'
                    bitsPerSymbol = 6;
            end
            
            subcarriersPerPRB = 12;
            OFDMSymbolsPerPRB = 7;
            
            bitsPerResourceElement = bitsPerSymbol*obj.nodeCodeRates(nodeID);
            ResourceElementsPerPRB = subcarriersPerPRB * OFDMSymbolsPerPRB;
            bitsPRB = floor(ResourceElementsPerPRB * bitsPerResourceElement);
            
            requiredPRBs = ceil(bits/bitsPRB);
            %unroundedPRB = (bits/bitsPRB);
            
            % Remove necessary bits from queues since they are now
            % transmitted
            if requiredPRBs > obj.maxAvailablePRBs
                % Update queue to show remaining bits
                PRBallocated = obj.maxAvailablePRBs;
                obj.bitQueueSize(nodeID) = bits - obj.maxAvailablePRBs*bitsPRB;
            else
                PRBallocated = requiredPRBs;
                obj.bitQueueSize(nodeID) = 0;
            end
            
        end
        
        function determineMCS(obj,nodeID)
            
            %FIX LATER
            obj.nodeCodeRates(nodeID) = 948/1024;
            obj.nodeModulation{nodeID} = 'QPSK';
            
        end
        
    end
    
    methods
        function viewGrid(obj)
            
            figure(obj.figID);
            %subplot(aps,1,obj.apID);
            surf(obj.resourceGrid);
            view(0,90)
            xlabel('Resource Blocks (Time 1 Block=0.5ms)');
            ylabel('Resource Blocks (Frequency 1 Block=180KHz)');
            
        end
    end
    
end