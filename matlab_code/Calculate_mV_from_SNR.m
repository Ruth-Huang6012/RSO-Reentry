function [mV] = Calculate_mV_from_SNR(D_aper, L_focal, p_pixel, t_int, Qe, SNR,angularRate, varargin)
% Required inputs: range (m), phaseAngle (rad), Aperture diameter (m), Integration time (sec), Quantum efficiency
% Optional inputs are: Dark current (default is 0.2 electrons/pixel/s), Readout noise (default is 2.5 electrons/pixel), focal length (default is 0.01 m), Pixel pitch (default is 5.5e-6 m)
% stray light (default is 0 - no stray light), refectivity (defaultvalue is 0.2), and central wavelength (default value is 5.5e-7 m), Number of pixels in object PSF 
% (Default is 4: 2x2 area), useAngularRate: toggle to indicate whether angular rate will be used to calculate number of pixels instead of direct input, 
% angular rate (default is 5.5e-3 rad/s) 

% Setup input parser
p = inputParser; % Get the input parser handle
p.StructExpand = 0;% Allows for the read in of structure in structure format
defaultString = '';% Sets the default string to an empty string for inputs that have not been entered
validTextInput = @(x) ischar(x); %Verify that the input variable is specified as character vector 

%Define required inputs                                                                                                     
addRequired(p, 'D_aper'); %Aperture diameter of sensor in meters                                               
addRequired(p, 't_int'); %Integration time in seconds                                                   
addRequired(p, 'Qe');    %Quantum efficiency      
addRequired(p, 'SNR');    %Visual Magnitude
addRequired(p, 'angularRate');  %Angular rate in rad/s
addRequired(p, 'L_focal') %Focal length in m
addRequired(p, 'p_pixel') %Pixel pitch in m

%Define optional inputs with their default values
addParameter(p, 'Dc', 0.2) %Dark current in electrons/pixel/s
addParameter(p, 'RN', 2.5) %Reaout noise in electrons/pixel
addParameter(p, 'strayLight', 0) %Stray light in visual magnitude per square arcsec
addParameter(p, 'pixelNumPSF', 4) %Number of pixels in object PSF
addParameter(p, 'useAngularRate', 1) %Toggle to indicate whether to use angular rate of number of pixels provided
addParameter(p, 'tau', 0.8) %Net transmittance
addParameter(p, 'tau_atm', 1) %Atmospheric transmittance
addParameter(p, 'defocus', 1) %Factor to account for defocusing in signal and background flux. Default can be 0 or 0.5
addParameter(p, 'stackedIntegrations', 1) %Number of stacked integrations

parse(p, D_aper, L_focal, p_pixel,t_int, Qe, SNR,angularRate,varargin{:}); %Parse required inputs

%Parse optional inputs 
Dc = p.Results.Dc; 
RN = p.Results.RN;                                     
strayLight = p.Results.strayLight;  
pixelNumPSF=p.Results.pixelNumPSF;
useAngularRate=p.Results.useAngularRate;
tau=p.Results.tau;
tau_atm=p.Results.tau_atm;
defocus=p.Results.defocus;
stackedIntegrations=p.Results.stackedIntegrations;
%% Constants
mvSky=20; %visual magnitude of the sky per square arcsec. Started with 17
streakWidth=2; %Streak is 2 pixels in width
mvbckg=mvSky+strayLight; %Visual magnitude for all background sources per square arcsec
%% Calculate Signal

A = pi.*D_aper.^2./4; %Aperture area
theta_pixel=p_pixel./L_focal;%instantaneous field of view (IFOV)/Angular scale of pixel in rad
t_signal = min(theta_pixel./angularRate,t_int); %Signal integration time

%% Calculate number of pixels RSO covers due to smear
if useAngularRate~=0
    StreakLength=sqrt(pixelNumPSF) * ( 1 + angularRate * t_int / theta_pixel ); %Length of the streak due to smear
    n_pixel=ceil(streakWidth.*StreakLength); %Number of pixels covered by RSO
else
    n_pixel=pixelNumPSF;
end
%% Calculate Background Noise
Lb = 5.6e10*10.^(-0.4.*mvbckg)*(180/pi)^2*3600^2; %Background signature in ph/sec/m^2/sr
eb = Qe*tau*Lb*A*theta_pixel^2*t_int; %Number of background photoelectrons
%% Calculate SNR
%SNR = es/sqrt(eb+RN^2*n_pixel+(Dc*t_int)^2*n_pixel);
es = SNR*sqrt((eb.*stackedIntegrations)+(RN.*sqrt(stackedIntegrations))^2+(Dc.*t_int.*stackedIntegrations))/(defocus.*stackedIntegrations);
E_RSO = es./(Qe.*tau*A.*tau_atm.*t_signal); %Signal photoelectron
mV =logb(E_RSO./(5.6e10), 10^(-0.4)); 