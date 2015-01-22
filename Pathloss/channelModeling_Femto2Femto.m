%% References
% [1] IST-WINNER D1.1.2 P. Kyösti, et al., "WINNER II Channel Models", ver 1.1, Sept. 2007. Available: https://www.ist-winner.org/WINNER2-Deliverables/D1.1.2v1.1.pdf

%clear all;close all;clc;

%% Overview
% The goal of this model is to measure the SINR of a dual transmitter
% network, consisting of 2 femtocells.  Each transmitter
% or base station will have one node or UE attached to them.

% Path Losses
% Line of site
f_c = 1.8; % GHz
h_BS = 25; % Meters, Height of base station
h_MS = 1.5; % Meters, Height of UE
Femto2Femto = 10;
Walls = 2; % Walls between femtocells
distance = 1:0.01:(Femto2Femto-1); %Meters, Distance from Femto1

[PL_Femto1,sigmas_Femto1] = FemtoAnimatePathLoss(distance,f_c,Walls);
[PL_Femto2,sigmas_Femto2] = FemtoAnimatePathLoss(Femto2Femto-distance,f_c,Walls);

% Antenna Gains
Femto_ant = 5; % dBi Omni
UE_ant = 1.04;

% Transmission Power
Femto_Tx_Power = 20; % dBm


runs = 1e3;
[Rx_Power_Vec,Int_Power_Vec,SINR_Femto_Vec1,SINR_Femto_Vec2] = deal(zeros(runs,length(distance)));
for run=1:runs
    
    % Fading
    %Fading = sqrt(sigma)*randn(1);
    Fading_Femto1 = log(lognrnd(0,sigmas_Femto1));
    Fading_Femto2 = log(lognrnd(0,sigmas_Femto2));
    
    % Received Power
    Rx_Power_Vec(run,:) = Femto_Tx_Power + Femto_ant - PL_Femto1 + UE_ant - Fading_Femto1;
    % Interfering Power
    Int_Power_Vec(run,:) = Femto_Tx_Power + Femto_ant - PL_Femto2 + UE_ant - Fading_Femto2;
    % SINR
    N = randn(1,length(distance));
    SINR_Femto_Vec1(run,:) = Rx_Power_Vec(run,:) - (Int_Power_Vec(run,:) + N);
    
    % SINR of Macro User
    SINR_Femto_Vec2(run,:) = Int_Power_Vec(run,:) - (Rx_Power_Vec(run,:) + N);
    
end

% Average
Rx_Power = mean(Rx_Power_Vec,1);
Int_Power = mean(Int_Power_Vec,1);
SINR_Femto_Vec1 = mean(SINR_Femto_Vec1,1);
SINR_Femto_Vec2 = mean(SINR_Femto_Vec2,1);

% Plot
figure(1);
plot(distance,PL_Femto1);
hold on; plot(distance,PL_Femto2,'r'); hold off;
xlabel('Distance (Meters)');
ylabel('Path Loss (dB)');
title('Pathloss Moving away from Femtocell1 towards Femtocell2');
grid on;
legend('Femtocell1','Femtocell2');

figure(2);
plot(distance,Rx_Power,distance,Int_Power);
xlabel('Distance (Meters)');
ylabel('Power (dB)');
title('UE Receive Power over Distance');
grid on;
legend('Rx_Power','Int_Power');

figure(3);
plot(distance,SINR_Femto_Vec1,distance,SINR_Femto_Vec2);
xlabel('Distance (Meters)');
ylabel('SINR (dB)');
title('SINR as moving away from Femtocell towards Macrocell');
grid on;
legend('MacroCell User','Femtocell User');

% CQI = load('CQI.mat');
% CQI = CQI.CQI;
% SNR = -100:1:100;

% % Map Values
% clear CQI_Mapping;
% for x=1:length(SINR_Macro_Vec)
%     SINR = SINR_Macro_Vec(x);
%     [~, idx] = min(abs(SNR - SINR));
%     CQI_Mapping(x) = CQI(idx);
% end

% CQIs = unique(CQI);
% CQIs = sort(CQIs);
% for x=1:length(CQIs)
%    CQIVect = CQIs(x)*ones(length(SINR_Macro_Vec));
%    hold on;plot(CQIVect);hold off;
% end


