function [pl,sigma] = getPathLoss(distance,f_c,h_BS,h_MS,scenario,LOS,d_in,d_out,walls)

sigma = 0;
c = 3e8;

switch scenario
    
    case 'C1'
        % C1 Suburban macro-cell
        if LOS
            pl = 40.0*log10(distance) + 11.65 - 16.2*log10(h_BS) - 16.2*log10(h_MS) + 3.8*log10(f_c/5.0);
            sigma = 6;
        end
    case 'C2'
        % C2 Typical urban macro-cell
        if LOS
            d_prime_bp = 4*(h_BS-1)*(h_MS-1)*f_c/c;
            if distance<d_prime_bp
                A = 26; B = 39; C = 20; X = 0;
                pl = A*log10(distance) + B + C*log10(f_c/5.0) + X;
                sigma = 4;
            else
                pl = 40.0*log10(distance) + 13.47 - 14.0*log10(h_BS-1) - 14.0*log10(h_MS-1) + 6.0*log10(f_c/5.0);
                sigma = 6;
            end
        else
            pl = (44.9 - 6.55*log10(h_BS))*log10(distance) + 34.46 + 5.83*log10(h_BS) + 23*log10(f_c/5.0);
            sigma = 8;
        end
    case 'C4'
        % C4 Urban Macro outdoor to indoor
        if LOS
            error('No LOS case for C4');
        else
            % Assuming Macro to wall of building is LOS
            % PLC2
            dist = d_out + d_in;
            if walls<=1 % LOS C2
                d_prime_bp = 4*(h_BS-1)*(h_MS-1)*f_c/c;
                if d_out<d_prime_bp
                    A = 26; B = 39; C = 20; X = 0;
                    PLC2 = A*log10(dist) + B + C*log10(f_c/5.0) + X;
                else
                    PLC2 = 40.0*log10(dist) + 13.47 - 14.0*log10(h_BS-1) - 14.0*log10(h_MS-1) + 6.0*log10(f_c/5.0);
                end
            else % Basically NLOC C2
                PLC2 = (44.9 - 6.55*log10(h_BS))*log10(dist) + 34.46 + 5.83*log10(h_BS) + 23*log10(f_c/5.0);
                
            end
            %PLC2 = 40.0*log10(d_out) + 13.47 - 14.0*log10(h_BS) - 14.0*log10(h_MS) + 6.0*log10(f_c/5.0);
            
            %pl = PLC2*(d_out + d_in) + 17.4 + 0.5*d_in - 0.8*h_MS;
            pl = PLC2 + 17.4 + 0.5*d_in - 0.8*h_MS;
            
            sigma = 10;
            
        end
        
    case 'A1'
        % A1 In building
        if LOS
            A = 18.7; B = 46.8; C = 20; X = 0;
            pl = A*log10(distance) + B + C*log10(f_c/5.0) + X;
            sigma = 3;
        else
            NumWalls = walls;
            disp(['Walls: ',num2str(walls)]);
            A = 20; B = 46.4; C = 20; X = 5*NumWalls; % If heavy walls change 5 to 12 | Assumes room to room model, If Coridor to room subtrack 1 from NumWalls
            pl = A*log10(distance) + B + C*log10(f_c/5.0) + X;% Assumes light walls (Residential should have light walls)
            sigma = 6;
        end
    case 'A2'
        % A2 BS in building, UE outsize
        if LOS
            error('A2 only provides NLOS options');
            
        else
            % Assuming LOS to wall from UE
            dist = d_out + d_in;            
            d_prime_bp = 4*(h_BS-1)*(h_MS-1)*f_c/c;
            if d_out<d_prime_bp
                A = 22.7; B = 41; C = 20; X = 0;
                PLB1 = A*log10(dist) + B + C*log10(f_c/5.0) + X;
            else
                PLB1 = 40*log10(dist) + 9.54 - 17.3*log10(h_BS-1) - 17.3*log10(h_MS-1) + 2.7*log10(f_c/5.0);            
            end
            pl_b = PLB1;
            
            
            theta = 0;
            pl_tw = 14 + 15*(1-cos(theta))^2;
            
            pl_in = 0.5*d_in;
            
            pl = pl_b + pl_tw + pl_in;

            sigma = 7;
        end
end


end