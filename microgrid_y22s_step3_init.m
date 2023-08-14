%% Microgrid Simulation
% Created: ECE 530 class of spring 2022

clc
close all
clear
format compact



%% Simulation settings

simu.endTime = 24*60*60;
simu.maxStepSize = 1e-1;



%% Data

load windspeedtimeseries

% Scale down
windspeedtimeseries.Data = 0.8*windspeedtimeseries.Data;



%% Wind Turbine Parameters

wt.rho = 1.2; % Density of air kg/m^3

% XANT 100 kW
wt.Pgen_rated = 100e3;
wt.Kfric = 0.01*100e3/6^2;    % Nm/(rad/s)    B*6^2 = 0.01*100e3
wt.bladeLength = 11;
wt.bladeWeight = 1000;    % From http://windpower.sandia.gov/other/041605C.pdf
wt.J = 3*1/3*wt.bladeWeight*wt.bladeLength^2;  % Missing generator, gearbox, shaft, etc...

wt.A = pi*wt.bladeLength^2;

wt.bladeActuatorTimeConstant = 0.5;    % Time constant for response of hydraulic system that positions blades to desired angle

wt.w_0 = 0;


% Cp curve modeling
% Uncomment below to plot Cp
% lambdaai = 1/(1/(lambda+0.08*beta)) - 0.035/(beta^3+1))
% cp = c1*(c2/lambdaai-c3*beta-c4)*exp(-c5/lambdaai) + c6*lambda
% wt.c = [...
%     0.5176 ...
%     116 ...
%     0.4 ...
%     5 ...
%     21 ...
%     0.0068];
% figure
% lambda = [0:0.1:13];
% for beta = [0:5:30];
%     lambdaai = 1./(1./(lambda+0.08*beta) - 0.035./(beta.^3+1));
%     cp = wt.c(1)*(wt.c(2)./lambdaai - wt.c(3)*beta - wt.c(4)) .* exp(-wt.c(5)./lambdaai) + wt.c(6)*lambda;
%     hold on
%     plot(lambda,cp)
%     hold off
% end
% axis([0 13 0 0.5])
% xlabel('lambda (tip speed ratio)')
% ylabel('Cp')


% From Cp(lambda) plot
wt.lambda_opt = 8.1;
wt.Cp_max = 0.48;

% Region 2 and 3 boundary -> rated rotational speed and wind speed
wt.u0_rated = (wt.Pgen_rated/(wt.Cp_max*0.5*1.2*wt.A))^(1/3);   % P_rated = Cp_max*0.5*A*bladeLength*u0_rated^3
wt.w_rated = wt.lambda_opt*wt.u0_rated/wt.bladeLength;

% Speed controller
% Turbine rated torque ~ 16.7 kNm
wt.speedcontroller.kp = 17000/6; % Ballpark (initial) design
wt.speedcontroller.ki = (17000/10)/6;  % maps error to rate of change of control action
wt.speedcontroller.kp = wt.speedcontroller.kp*6; % Make controller more agressive (faster); this adjustment works better than initial design
wt.speedcontroller.ki =  wt.speedcontroller.ki*6; % Make controller more agressive (faster); this adjustment works better than initial design
wt.speedcontroller.lowerLimit = 0; 
wt.speedcontroller.upperLimit = 5*17e3;
wt.speedcontroller.kt = 1;
wt.speedcontroller.int_0 = 0;

% Power controller
wt.powercontroller.kp = 5/100e3;       % Power error of 100 kW actuates 5 degrees of pitch
wt.powercontroller.ki = (5/2)/100e3;     % Power error of 100 kW actuates 5 degress of pitch in two seconds
wt.powercontroller.int_0 = 0;
wt.powercontroller.kt = 1;
wt.powercontroller.upperLimit = 30;    % Maximum degrees of pitch
wt.powercontroller.lowerLimit = 0;     % Minimum degrees of pitch