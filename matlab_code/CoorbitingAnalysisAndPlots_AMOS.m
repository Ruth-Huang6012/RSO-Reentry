% CoorbitingAnalysisAndPlots
function [approachData]= CoorbitingAnalysisAndPlots_AMOS(Integration_time, focalLength,Qe,D_aper,pixelPitch,DC,RN,tau, ObjD)
% Close old plots
close all

% Load the orbit data from the sensitivity analysis
%cd("C:\Users\randa\MATLAB Drive\AMOS 2024")
%%load('OrbitOutputs1.mat');
%load('OrbitOutputs_2.mat');
%load('OrbitOutputs_3.mat');
%load('OrbitOutputs_4.mat');

load('OrbitOutputs0200.mat');
load('RedwingOutputs200.mat');
SMAs = TargetSMAs;

% Extract length of data
nPoints = length(Targetpos);
nRso    = 1; %%size(TargetPosRW_Frame,3);

% Sun direction in ECI
uSunEci = [ 1 0 0 ];

% Define RSO properties
objDiameter     = ObjD; % m
objReflectivity = 0.2;

%Define Sensor Data
%Integration_time    = 0.1; %100 ms exposure time
%f_number            = 0.8; %Sensor f-number
%focalLength         = 0.0136; %Focal length of the sensor in m
%Qe                  = 0.66; %Quantum efficiency assumption 
%D_aper              = focalLength ./ f_number; %calculate aperture diameter in m
%pixelPitch          = 2.6e-5; %Pixel pitch in m
%DC                  = 529; %Dark current in el/pixel/s. FAI has DC of 529 el/s
%RN                  = 10; %Readout noise in el/pixel. FAI has a value of 4 at 20 kHz and 12 and 1 MhZ. Assuming RN = 10 as conservative estimate
%tau                 = 0.36; %Optical transmittance. There are three components to the transmittance: the lens transmission (0.8); the NIR filter (0.9); and the taper (0.5).  Together this makes 0.8 * 0.9 * 0.5 = 0.36 for total transmittance.

% Define constants
proxThresholdKm = 550;

% Figure positions
figPosition = [ 100 100 900 400 ];

% Obtain Redwing-Object distance data
rwToObjDist = reshape(distFromRW,[nPoints nRso]);

% Plot Redwing-Object distances
%f1 = figure();
%semilogy(t/timeStep,rwToObjDist/1000)
%xlabel('Time (hour)')
%ylabel('Distance (km)')
%grid on
%title('Host-Object Distance vs Time')
%hold on
%p1=plot([t(1) t(nPoints)]/timeStep,proxThresholdKm * [1 1],'k--');
%hold off
%set(gcf,'Position',figPosition)
%legend(p1,'550 km threshold',Location='southeast');
%saveas(f1,"approaches.jpg");

% Initialize arrays
uRwToRsoOrb     = zeros(nPoints,3,nRso);
solarPhaseAngle = zeros(nPoints,nRso);
objMagnitude    = zeros(nPoints,nRso);
SNR             = zeros(nPoints,nRso);
nApproaches     = zeros(nRso,1);
approachData    = zeros(nRso*2,34); 

% Initialize total number of RSO approaches
nTotalApproaches = 0;

%f2 = figure();
%hold on

for iRso = 1 : nRso

    for iPoint = 1 : nPoints
    
        % Get unit vectors for Redwing orbit frame
        uRwOrbitNormal      = UnitVector(cross(REDWING_Pos(iPoint,:),REDWING_Vel(iPoint,:)));
        uRwOrbitZenith      = UnitVector(REDWING_Pos(iPoint,:));
        uRwOrbitVelocity    = UnitVector(cross(uRwOrbitNormal,uRwOrbitZenith));

        dcmOrbToEci = [ uRwOrbitNormal; uRwOrbitVelocity; uRwOrbitZenith ];
    
        uRwToRsoEci = UnitVector( TargetPosRW_Frame(iPoint,:,iRso) );

        solarPhaseAngle(iPoint,iRso) = pi - acos( uRwToRsoEci * uSunEci' );

        objMagnitude(iPoint,iRso) = CalculateVisualMagnitude_ShellUpdated(objDiameter(iRso),objReflectivity,rwToObjDist(iPoint,iRso),solarPhaseAngle(iPoint,iRso));
        objDiameter(iRso);
        uRwToRsoOrb(iPoint,:,iRso) = uRwToRsoEci * dcmOrbToEci';  
    
    end

    % Find occasions where the object is within the proximity threshold 
    indProx = find(rwToObjDist(:,iRso) <= proxThresholdKm);
    nProx   = length(indProx);

    % Determine the number of close approaches
    if nProx == 0
        indApproachStart    = 0;
        indApproachEnd      = 0;
        nApproaches(iRso)   = 0;
    else
        diffIndProx         = diff(indProx);
        indTimeJumps        = find( diffIndProx > 1 );
        indApproachStart    = [ indProx(1); indProx( indTimeJumps + 1 ) ];
        indApproachEnd      = [ indProx( indTimeJumps ); indProx(nProx) ];
        nApproaches(iRso)   = length(indApproachStart);
    end

    % Plot the unit vector direction for each close approach
    
    for iApproach = 1 : nApproaches(iRso)

        % Increment the number of total RSO approaches
        nTotalApproaches = nTotalApproaches + 1;

        % Define the timeframe for the current approach
        indApproach = indApproachStart(iApproach) : indApproachEnd(iApproach);
        lenApproach = indApproachEnd(iApproach) - indApproachStart(iApproach) + 1;
        if lenApproach == 1
            nTotalApproaches = nTotalApproaches - 1;
            continue
        end 

        % Extract the Redwing-to-RSO vectors in orbit frame for the
        % approach
        uRwToRsoOrbVectors = uRwToRsoOrb(indApproach,:,iRso);

        % Find the minimum distance between Redwing and the RSO during the approach 
        [ rwToObjDistAtMinDistance , indMinDistRwToRso ] = min( rwToObjDist(indApproach,iRso) );

        % Find the point of minimum angular rate, using small-angle
        % assumption
        diffRwToRsoOrbVectors                   = diff(uRwToRsoOrbVectors);
        VectorMag(diffRwToRsoOrbVectors(lenApproach-1,:));
        angularStep                             = [ VectorMag(diffRwToRsoOrbVectors,1); VectorMag(diffRwToRsoOrbVectors(lenApproach-1,:),1) ];%[ VectorMag(diffRwToRsoOrbVectors,1); VectorMag(diffRwToRsoOrbVectors(lenApproach-1) ];
        [ objStepAtMinAngleRate , indMinStep ]  = min( angularStep );

        % Calculate the angular step of RSO at other points
        objAngularStepAtEntry       = angularStep(1); 
        objAngularStepAtExit        = angularStep(lenApproach); %angularStep(lenApproach-1);
        objAngularStepAtMinDistance = angularStep(indMinDistRwToRso);

        % Calculate the distance between Redwing and RSO at other points
        rwToObjDistAtEntry          = rwToObjDist(indApproach(1),iRso); 
        rwToObjDistAtExit           = rwToObjDist(indApproach(lenApproach),iRso);
        rwToObjDistAtMinAngleRate   = rwToObjDist(indApproach(indMinStep(1)),iRso);

        % Obtain angles to zenith
        angleToZenithAtEntry        = acos( uRwToRsoOrbVectors(1,1) );
        angleToZenithAtExit         = acos( uRwToRsoOrbVectors(lenApproach,1) );
        angleToZenithAtMinAngleRate = acos( uRwToRsoOrbVectors(indMinStep(1),1) );
        angleToZenithAtMinDistance  = acos( uRwToRsoOrbVectors(indMinDistRwToRso(1),1) );

        % Obtain angles to velocity
        angleToVelocityAtEntry        = acos( uRwToRsoOrbVectors(1,2) );
        angleToVelocityAtExit         = acos( uRwToRsoOrbVectors(lenApproach,2) );
        angleToVelocityAtMinAngleRate = acos( uRwToRsoOrbVectors(indMinStep(1),2) );
        angleToVelocityAtMinDistance  = acos( uRwToRsoOrbVectors(indMinDistRwToRso(1),1) );

        % Obtain angles to orbit normal
        angleToOrbitNormalAtEntry        = acos( uRwToRsoOrbVectors(1,3) );
        angleToOrbitNormalAtExit         = acos( uRwToRsoOrbVectors(lenApproach,3) );
        angleToOrbitNormalAtMinAngleRate = acos( uRwToRsoOrbVectors(indMinStep(1),3) );
        angleToOrbitNormalAtMinDistance  = acos( uRwToRsoOrbVectors(indMinDistRwToRso(1),3) );
        
        % Obtain solar phase angles

        solarPhaseAngleAtEntry          = solarPhaseAngle(indApproachStart(iApproach),iRso);
        solarPhaseAngleAtExit           = solarPhaseAngle(indApproachEnd(iApproach),iRso);
        solarPhaseAngleAtMinAngleRate   = solarPhaseAngle(indApproach(indMinStep),iRso);
        solarPhaseAngleAtMinDistance    = solarPhaseAngle(indApproach(indMinDistRwToRso),iRso);

        % Obtain magnitudes
        objMagnitudeAtEntry          = objMagnitude(indApproachStart(iApproach),iRso);
        objMagnitudeAtExit           = objMagnitude(indApproachEnd(iApproach),iRso);
        objMagnitudeAtMinAngleRate   = objMagnitude(indApproach(indMinStep),iRso);
        objMagnitudeAtMinDistance    = objMagnitude(indApproach(indMinDistRwToRso),iRso);

        %Obtain SNR
        SNRAtEntry                   = Calculate_SNR_from_mV_ShellUpdated (D_aper, focalLength,pixelPitch,Integration_time, Qe, objMagnitudeAtEntry,objAngularStepAtEntry / timeStep,"DC",DC,"RN",RN,"tau",tau);
        SNRAtExit                    = Calculate_SNR_from_mV_ShellUpdated (D_aper, focalLength,pixelPitch,Integration_time, Qe, objMagnitudeAtExit,objAngularStepAtExit / timeStep,"DC",DC,"RN",RN,"tau",tau);
        SNRAtAtMinAngleRate          = Calculate_SNR_from_mV_ShellUpdated (D_aper, focalLength,pixelPitch,Integration_time, Qe, objMagnitudeAtMinAngleRate,objStepAtMinAngleRate / timeStep,"DC",DC,"RN",RN,"tau",tau);
        SNRAtMinDistance             = Calculate_SNR_from_mV_ShellUpdated (D_aper, focalLength,pixelPitch,Integration_time, Qe, objMagnitudeAtMinDistance,objAngularStepAtMinDistance / timeStep,"DC",DC,"RN",RN,"tau",tau);

        % Plot the trajectories for each approach relative to Redwing
        plot3(uRwToRsoOrbVectors(:,1,:),uRwToRsoOrbVectors(:,2,:),uRwToRsoOrbVectors(:,3,:),'.-');
        % Add a label for each close approach
        %text(uRwToRsoOrbVectors(1,1,:),uRwToRsoOrbVectors(1,2,:),uRwToRsoOrbVectors(1,3,:),sprintf('Obj %d: App: %d',iRso,iApproach));

        % Save approach data to table
        approachData(nTotalApproaches,1)        = iRso;
        approachData(nTotalApproaches,2)        = iApproach;
        approachData(nTotalApproaches,3)        = ( objAngularStepAtEntry / timeStep ) * 3600 * 180/pi;
        approachData(nTotalApproaches,4)        = ( objAngularStepAtExit / timeStep ) * 3600 * 180/pi;
        approachData(nTotalApproaches,5)        = ( objStepAtMinAngleRate / timeStep ) * 3600 * 180/pi;
        approachData(nTotalApproaches,6)        = ( objAngularStepAtMinDistance / timeStep ) * 3600 * 180/pi;
        approachData(nTotalApproaches,7)        = rwToObjDistAtEntry;% / 1000;
        approachData(nTotalApproaches,8)        = rwToObjDistAtExit;% / 1000;
        approachData(nTotalApproaches,9)        = rwToObjDistAtMinAngleRate;% / 1000; 
        approachData(nTotalApproaches,10)       = rwToObjDistAtMinDistance;% / 1000;
        approachData(nTotalApproaches,11)       = angleToZenithAtEntry * 180/pi;
        approachData(nTotalApproaches,12)       = angleToZenithAtExit * 180/pi;
        approachData(nTotalApproaches,13)       = angleToZenithAtMinAngleRate * 180/pi;
        approachData(nTotalApproaches,14)       = angleToZenithAtMinDistance * 180/pi;
        approachData(nTotalApproaches,15)       = angleToVelocityAtEntry * 180/pi;
        approachData(nTotalApproaches,16)       = angleToVelocityAtExit * 180/pi;
        approachData(nTotalApproaches,17)       = angleToVelocityAtMinAngleRate * 180/pi;
        approachData(nTotalApproaches,18)       = angleToVelocityAtMinDistance * 180/pi;
        approachData(nTotalApproaches,19)       = angleToOrbitNormalAtEntry * 180/pi;
        approachData(nTotalApproaches,20)       = angleToOrbitNormalAtExit * 180/pi;
        approachData(nTotalApproaches,21)       = angleToOrbitNormalAtMinAngleRate * 180/pi;
        approachData(nTotalApproaches,22)       = angleToOrbitNormalAtMinDistance * 180/pi;
        approachData(nTotalApproaches,23)       = solarPhaseAngleAtEntry * 180/pi;
        approachData(nTotalApproaches,24)       = solarPhaseAngleAtExit * 180/pi;
        approachData(nTotalApproaches,25)       = solarPhaseAngleAtMinAngleRate * 180/pi;
        approachData(nTotalApproaches,26)       = solarPhaseAngleAtMinDistance * 180/pi;
        approachData(nTotalApproaches,27)       = objMagnitudeAtEntry;
        approachData(nTotalApproaches,28)       = objMagnitudeAtExit;
        approachData(nTotalApproaches,29)       = objMagnitudeAtMinAngleRate;
        approachData(nTotalApproaches,30)       = objMagnitudeAtMinDistance;
        approachData(nTotalApproaches,31)       = SNRAtEntry;
        approachData(nTotalApproaches,32)       = SNRAtExit;
        approachData(nTotalApproaches,33)       = SNRAtAtMinAngleRate;
        approachData(nTotalApproaches,34)       = SNRAtMinDistance;


    end

end

% Complete plot
%hold off
%axis([-1 1 -1 1 -1 1])
%axis('equal')
%grid on
%xlabel('Zenith')
%ylabel('Velocity')
%zlabel('Orbit Normal')
%saveas(f2, "FOV.jpg")

% Remove the empty rows

approachData = approachData(1:nTotalApproaches,:);
%save("approachData.mat","approachData");
%rwToObjDist = rwToObjDistAtMinDistance / 1000;
%orbit_normal = angleToOrbitNormalAtMinDistance * 180/pi;
%angles_to_zenith = angleToZenithAtMinDistance * 180/pi;
%solar_phase_angle = solarPhaseAngleAtMinDistance * 180/pi;
end

