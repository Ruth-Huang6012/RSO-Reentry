%% Input Parameters

%PH numCoorbit=1000; %Number of co-orbiting orbital elements to randomize
%numCoorbit  = 280; %PH
%% CASSIOPE Orbital Parameters
rE = 6.378e+3;
Inc_RW      = 80.9642 * pi/180;
RAAN_RW     = 332.1344 * pi/180;
ecc_RW      = 0.0584161;
ArgPer_RW   = 213.0991;
mu          = 3.986004418e5; %Standard gravitational parameter-------------------
TA_RW       = 147.767 * pi/180;%True anomaly in radians
MA_RW       = 143.2360 * pi/180; %Mean anomaly. Given true anomaly only.
MM_RW       = 14.4808435549221;
epoch       = 23080.22633997; %
SMA_RW      = rE+600.739384;
params_RW=struct('a',SMA_RW,'e',ecc_RW,'incl',Inc_RW,'Omega',RAAN_RW, ...
    'w',ArgPer_RW,'nu0',TA_RW, 'bstar', 0, 'xSec', 0);

%% Generate Normal Distributions in Loop

%Code can be uncommented to obtain new set of pseudo-random co-orbiting
%objects. Values from previous runs will be loaded by default.

% will need to be replaced with data from future re-entries

rng(0);


%filename = '/MATLAB Drive/Sensitivty Analysis Code/iss.tle';
tleStruct = tleread("iss.tle");

Inc_ISS      = tleStruct.Inclination;
RAAN_ISS     = tleStruct.RightAscensionOfAscendingNode;
ecc_ISS = tleStruct.Eccentricity;
ArgPer_ISS   = tleStruct.ArgumentOfPeriapsis;
%TA_RW       = 147.767 * pi/180;%True anomaly in radians
MA_ISS       = tleStruct.MeanAnomaly; %Mean anomaly. Given true anomaly only.
MM_ISS       = tleStruct.MeanMotion;
epoch_ISS       = tleStruct.Epoch; %
%SMA_ISS      = ((mu/(MM_ISS*240*2*pi/86400)^2)^(1/3));
bstar_ISS = tleStruct.BStar;
SMA_ISS = rE+400;
params_RW=struct('a',SMA_ISS,'e',ecc_ISS,'incl',Inc_ISS,'Omega',RAAN_ISS, ...
    'w',ArgPer_ISS,'nu0',MA_ISS, 'bstar', bstar_ISS, 'xSec', 1.5);



% % meanValues  = [6600e3,0,98,95]; %mean values for Smei-Major axis (m), eccentricity, inclination (deg), and RAAN (deg)
% meanValues  = [ 250*10^3, 0.005576, 97.1113 * 180/pi, 346.6313 * 180/pi, 2.7064*10^(-4)];
% sigma3      = [200*10^3,0.015,1,3, 1*10^(-4)]; %3-sigma for SMA, Ecc, Inc, RAAN
% numElements = size(meanValues,2); %Variable to store number of orbital elements to generate normal distribution for
% 
% for i = 1 : numElements %Loop through the 4 orbital elements
% 
%     standardNormalData  = randn(1, numCoorbit); %Generate randomized values with mean of 0 and standard deviation of 1
% 
%     normalData(:,i)     = meanValues(i)+sigma3(i)/3*standardNormalData; %Obtain a standard distribution using the mean and standard deviation for each orbital element
% 
% end


%import TLEs
% for TLE in folder:

path_directory='/MATLAB Drive/Sensitivity Analysis Code/TLEs'; 
 % Pls note the format of files,change it as required
original_files=dir([path_directory '/*.tle']); 
numCoorbit = 100;
MAs = zeros(numCoorbit);
ArgPeri = zeros(numCoorbit);
normalData  = zeros(numCoorbit,7);
epochs = repmat(datetime(0, 0, 0, 0,0,0,0, TimeZone="America/New_York"), numCoorbit);
decayed = zeros(numCoorbit);
RW_decayed = 0;
params_cos = repmat(struct('a', 0,'e', 0,'incl', 0,'Omega', 0, 'w',0,'nu0',0, 'mm', 0, 'bstar', 0, 'xSec', 0), numCoorbit, 1);
n = 0;
for i=1:length(original_files)
    if n>numCoorbit
        break
    end
    filename=[path_directory '/' original_files(i).name];
    tleStruct = tleread(filename);
    ID = tleStruct.SatelliteCatalogNumber;
    Inc      = tleStruct.Inclination * pi/180;
    RAAN     = tleStruct.RightAscensionOfAscendingNode * pi/180;
    ecc     = tleStruct.Eccentricity;
    ArgPer   = tleStruct.ArgumentOfPeriapsis;
    mu       = 3.986004418e+5; %Standard gravitational parameter-------------------
    %TA_RW       = 147.767 * pi/180;%True anomaly in radians
    MA       = tleStruct.MeanAnomaly * pi/180; %Mean anomaly. Given true anomaly only.
    %MA
    MM       = tleStruct.MeanMotion;
    epoch       = tleStruct.Epoch;
    SMA      = ((mu/(MM*240*2*pi/86400)^2)^(1/3));
    Bstar = tleStruct.BStar;
    if (SMA-rE < 400 && SMA-rE > 200)
        copyfile(filename,'TLEs/TLE copy');
        n = n+1;
        diameter = 0.5;
        url = strcat("https://discosweb.esoc.esa.int/api/objects?filter=eq(satno,", int2str(ID), ")");
        token = 'ImMwNzBmZTdiLWIyZmMtNDNhOS05YjM4LTIzMzc1NjI5NmE4ZiI.jnVD8J_iVXBt0fNQOZzsk40m9UY';
        options = weboptions('HeaderFields', {'Authorization' ['Bearer ',token]});
        try
            r = webread(url,options);
            diameter = r.data.attributes.diameter;
        catch E
            E
            diameter = 0.5;
        end
        isempty(diameter)
        if isempty(diameter)
            diameter = 0.5;
        end
        normalData(n,1) = SMA;
        normalData(n,2) = ecc;
        normalData(n,3) = Inc;
        normalData(n,4) = RAAN;
        normalData(n,5) = MM;
        normalData(n,6) = Bstar;
        normalData(n,7) = diameter;
        epochs(n) = epoch;
        MAs(n) = MA;
        ArgPeri(n) = ArgPer;
    end
end


%TA              = 360* rand(1, numCoorbit)'; %Randomly assign true anomaly values between 0 and 360 degrees
%ArgPeri         = 360* rand(1, numCoorbit)';%Randomly assign argument of perigee values between 0 and 360 degrees


normalData(:,2) = abs(normalData(:,2)); %Eccentricity cannot be negative

% Calculate Position and velocity
numDays             = 30; %Number of days to calculate position for
timeStep            = 60; %Number of seconds for the timestep between subsequent position calculations
t                   = 0 : timeStep : 86400 * numDays; %Time vector in seconds (time since epoch)

% PH: Replace length(t) with a single call

REDWING_Pos         = zeros(length(t),3); %Initialize variable to store REDWING's ECI position vector (m)
REDWING_Vel         = zeros(length(t),3); %Initialize variable to store REDWING's ECI velocity vector (m/s)
Targetpos           = zeros(length(t),3,numCoorbit); %Initialize variable to store the ECI positions of the co-orbiting objects (m)
TargetPosRW_Frame   = zeros(length(t),3,numCoorbit);  %Initialize variable to store the positions of the co-orbiting objects in REDWING's reference frame (m)
Targetvel           = zeros(length(t),3,numCoorbit); %Initialize variable to store the ECI velocities of the co-orbiting objects (m/s)
TargetSMAs = zeros(length(t),numCoorbit);
RW_SMA = zeros(length(t),1);
% distFromRW          = zeros(length(t),numCoorbit);

for j=1: numCoorbit %Loop through each co-orbiting object
        params_RW=struct('a',SMA_ISS,'e',ecc_ISS,'incl',Inc_ISS,'Omega',RAAN_ISS, ...
            'w',ArgPer_ISS,'nu0',MA_ISS, 'bstar', bstar_ISS, 'xSec', 1.5);
        params_co   = struct('a', normalData(j,1),'e', normalData(j,2),'incl', deg2rad(normalData(j,3)),'Omega', deg2rad(normalData(j,4)), ... %Create a struct with the orbital elements of ...
            'w',deg2rad(ArgPeri(j)),'nu0',deg2rad(MAs(j)), 'mm', normalData(j,5), 'bstar', normalData(j,6), 'xSec', normalData(j,7)); %each co-orbiting object. To match the input of the position calculator function, the angles are converted to radians
        params_cos(j) = struct('a', normalData(j,1),'e', normalData(j,2),'incl', deg2rad(normalData(j,3)),'Omega', deg2rad(normalData(j,4)), ... %Create a struct with the orbital elements of ...
            'w',deg2rad(ArgPeri(j)),'nu0',deg2rad(MAs(j)), 'mm', normalData(j,5), 'bstar', normalData(j,6), 'xSec', normalData(j,7));
        %[r,v] = propagateOrbit([epochs(j), datetime(2024, 11, 25, 9, 30, 0, TimeZone="America/New_York")], normalData(j,1), normalData(j,2), deg2rad(normalData(j,3)), deg2rad(normalData(j,4)), deg2rad(ArgPeri(j)), deg2rad(MAs(j)));
        %r
        %v
        % if k == 1  
        % 
        %     % Orbit rate
        %     w_orbit = sqrt(mu/params_co.a^3);
        %     E0 = acos((params_co.e+cos(params_co.nu0))/(1+params_co.e*cos(params_co.nu0)));
        %     if params_co.nu0 > pi
        %         E0 = 2*pi - E0;   % Correct for the right quadrant
        %     end
        %     tp0 = (E0 - params_co.e*sin(E0))/w_orbit;
        % 
        %     % Determine the mean anomaly
        %     M = w_orbit * (t(1) + tp0);
        % 
        % 
        %     % Estimate the true anomaly (assumes low eccentricity)
        %     nu = M + 2*params_co.e*sin(M) + 1.25*params_co.e^2*sin(2*M);
        %     p = params_co.a*(1-params_co.e^2);
        %     R = p/(1+params_co.e*cos(nu));
        % end
        %[ts,z] = Integrator(params_co, t);
        RW_decayed = 0;
        for k = 1 : length(t) %Loop through full duration of study

            [REDWING_Pos(k,:), RW_sma]   = GetOrbitPositionECI(params_RW,t(k), timeStep, 0); %Calculate REDWING's ECI position for each point in time since the epoch (m)
            %RW_sma-rE
            RW_SMA(k) = RW_sma;
            if RW_decayed
                RW_SMA(k) = NaN;
            end
            if RW_sma-rE<80
                RW_decayed = 1;
            end
            params_RW.a = RW_sma;
            REDWING_Vel(k,:)    = GetOrbitVelocityECI(params_RW,t(k)); %Calculate REDWING's ECI velocity for each point in time since the epoch (m/s)
            if decayed(j)
                Targetvel(k, :, j) = [0,0,0];
                Targetpos(k, :, j) = [NaN, NaN, NaN];
                TargetSMAs(k,j) = NaN;
                TargetPosRW_Frame(k, :, j) = [NaN, NaN, NaN];
            else
                Targetvel(k,:, j)            = GetOrbitVelocityECI(params_co, t(k));
                [Targetpos(k,:,j), sma]      = GetOrbitPositionECI(params_co, t(k), timeStep, 1);
                RSO = Targetpos(k,:,j);
                RW = REDWING_Pos(k,:);
                TargetPosRW_Frame(k,:,j)    = Targetpos(k,:,j) - REDWING_Pos(k,:);
                TargetSMAs(k,j) = sma;
                if sma < rE+80
                    decayed(j) = 1;
                end
            end
            
            params_co.a = TargetSMAs(k,j);

        end
        %Targetvel(k,:,j)            = GetOrbitVelocityECI(params_co,t(k));   %Calculate the ECI velocity of each co-orbiting object for each point in time (m)
        %velocity = sqrt(sum(Targetvel(k,:,j).^2));
        %Targetpos(k,:,j)      = GetOrbitPositionECI(params_co,t(k), velocity, timeStep);   %Calculate the ECI position of each co-orbiting object for each point in time (m)
         %Calculate the position of each co-orbiting object for each point in time in REDWING's reference frame (m)
        
        %normalData(j,1) = TargetSMAs(k,j);
    

end
% for i =1: length(RW_SMA)
%     if not(isnan(RW_SMA(i)))
%         RW_SMA(i)-rE
%         i
%     end
% end

distFromRW = sqrt(TargetPosRW_Frame(:,1,:).^2 + TargetPosRW_Frame(:,2,:).^2 + TargetPosRW_Frame(:,3,:).^2);    %Calculate the distance between REDWING for each co-orbiting object at each point in time (m)
%Save ECI positions and velocities to .mat file (file can be read in
%directly in future sensitivity analysis to save computation time)


save("OrbitOutputs.mat", "t","timeStep","REDWING_Pos","REDWING_Vel"); 
save("OrbitOutputs_3.mat", "Targetpos","Targetvel");
save("OrbitOutputs_2.mat", "TargetPosRW_Frame", "distFromRW","normalData");
save("OrbitOutputs_4.mat", "ArgPeri","MAs","params_RW", "TargetSMAs", "RW_SMA");

save("Params.mat", "params_cos");

%get rid of ArgPeri, MAs, everything else stays the same




%RW_SMA_600 = RW_SMA;
%save("RW_SMAs.mat", "RW_SMA_600", '-append') %, '-append'