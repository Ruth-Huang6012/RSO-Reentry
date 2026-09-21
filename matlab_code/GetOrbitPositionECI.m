%%% r = GetOrbitPositionECI(params,t)
%
% Obtain the satellite position vector in ECI frame
%
% Inputs:
%        params        - structure containing the Keplerian elements
%        t             - time value (sec)
%
% Outputs:
%        r            - satellite position vector in ECI frame (m)

function [r, sma] = GetOrbitPositionECI(params,t, timestep, decay)

% Gravitational parameter in m^2/s^3
mu = 3.985992e+05;   
rE = 6.378e+3;
b =  params.bstar/rE; 
%decay = 0;
% Orbit rate
w_orbit = sqrt(mu/params.a^3);

% Determine the initial eccentric anomaly and the initial time since periapsis passage
E0 = acos((params.e+cos(params.nu0))/(1+params.e*cos(params.nu0)));
if params.nu0 > pi
    E0 = 2*pi - E0;   % Correct for the right quadrant
end
tp0 = (E0 - params.e*sin(E0))/w_orbit;

% Determine the mean anomaly
M = w_orbit * (t + tp0);

% Estimate the true anomaly (assumes low eccentricity)
nu = M + 2*params.e*sin(M) + 1.25*params.e^2*sin(2*M);

% Define initial position vector
if decay
    [period, a] = computeOrbitalDecay(params.a, params.e, b, timestep);
else
    a = params.a;
end
p = a*(1-params.e^2);
R = p/(1+params.e*cos(nu)); 
%delR = (b* velocity^2/w_orbit)*100;
%R = R-delR;
r = [R*cos(nu) R*sin(nu) 0];

% Rotate about the ECI Z axis by the argument of perigee
cw = cos(params.w);
sw = sin(params.w);
r = [r(1)*cw - r(2)*sw, r(1)*sw + r(2)*cw, r(3)];
%Rw = [cos(w) -sin(w) 0; sin(w) cos(w) 0; 0 0 1];

% Rotate about the ECI X axis by the inclination
ci = cos(params.incl);
si = sin(params.incl);
r = [r(1), r(2)*ci - r(3)*si, r(2)*si + r(3)*ci];

% Rotate about the ECI Z axis by the longitude of ascending node
co = cos(params.Omega);
so = sin(params.Omega);
r = [r(1)*co - r(2)*so, r(1)*so + r(2)*co, r(3)];
sma = R*(1+params.e*cos(nu)) / (1-params.e^2);
%Romega = [cos(Omega) -sin(Omega) 0; sin(Omega) cos(Omega) 0; 0 0 1];






