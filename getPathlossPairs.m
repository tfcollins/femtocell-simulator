function linkInfo = getPathlossPairs(apPositions)

% So far this model just assumes indoor pathloss, with no walls between
% nodes

f_c = 1.8e9;
h_BS = 1.5;
h_MS = 1.5;

% Calculate distances from pairs
numAPs = size(apPositions,1);
pairs = numAPs * (numAPs - 1);

linkInfo(numAPs).Tx(1:(numAPs-1))=zeros((numAPs-1),1);
linkInfo(numAPs).Distance=zeros((numAPs-1),1);
linkInfo(numAPs).Pathloss=zeros((numAPs-1),1);
linkInfo(numAPs).sigma=zeros((numAPs-1),1);


for k=1:numAPs
    
    link = 1:numAPs;
    link(k) = [];
    
    for AP = 1:(numAPs-1)
        
        linkInfo(k).Tx(AP) = link(AP);
        
        R = sqrt( (apPositions(k,1)-apPositions(link(AP),1))^2 + (apPositions(k,2)-apPositions(link(AP),2))^2);
        linkInfo(k).Distance(AP) = R;
        
        % Determine pathloss
        d_in = 0; d_out = 0; % Not used
        LOS = 1; % Line of sight
        scenario = 'A1';
        
        Walls = 0;%floor(distances(distance)/(Femto2WallDistance)); % Walls to transmit through
        if Walls>0; LOS = 0 ;end
        [PL,sigma] = getPathLoss(R,f_c,h_BS,h_MS,scenario,LOS,d_in,d_out,Walls);
        
        linkInfo(k).Pathloss(AP) = PL;
        linkInfo(k).sigma(AP) = sigma;
        
    end
end




end
