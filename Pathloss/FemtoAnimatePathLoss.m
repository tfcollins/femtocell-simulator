function [PL,sigmas] = FemtoAnimatePathLoss(distances,f_c,walls)


Femto2WallDistance = 5; % Meters
[PL,sigmas] = deal(zeros(size(distances)));

Floor = 1;
h_BS = 3*(Floor - 1) + 2;
h_MS = 1.5;
Wall2Outside = walls;


for distance = 1:length(distances)

    % Still Inside
    if distances(distance)<Femto2WallDistance*Wall2Outside
        d_in = 0; d_out = 0; % Not used
        LOS = 1;
        scenario = 'A1';
        
        Walls = floor(distances(distance)/(Femto2WallDistance)); % Walls to transmit through
        if Walls>0
            LOS = 0;
        end
        
        [PL(distance),sigmas(distance)] = getPathLoss(distances(distance),f_c,h_BS,h_MS,scenario,LOS,d_in,d_out,Walls);
        
    else % UE outside now
        LOS = 0;
        scenario = 'A2';
        d_out = distances(distance) - Femto2WallDistance;
        d_in = Femto2WallDistance;
        [PL(distance),sigmas(distance)] = getPathLoss(distances(distance),f_c,h_BS,h_MS,scenario,LOS,d_in,d_out);
    end


end