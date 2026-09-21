%%% r = GetOrbitPositionECI(params,t)
%
% Obtain the satellite position vector in ECI frame
%
% Inputs:
%        params        - structure containing the Keplerian elements
%        t             - time value (sec)
%
% Outputs:
%        v            - satellite velocity vector in ECI frame (m/s)

function v = GetOrbitVelocityECI(params,t)

% Gravitational parameter in m^2/s^3
mu = 3.985992e+05;   

% Orbit rate
w_orbit = sqrt(mu/params.a^3);
% Determine the initial eccentric anomaly and the initial time since periapsis passage
E0 = acos((params.e+cos(params.nu0))/(1+params.e*cos(params.nu0)));
if params.nu0 > pi
    E0 = 2*pi - E0;   % Correct for the right quadrant
end
tp0 = (E0 - params.e*sin(E0))/w_orbit; %tp0
% Determine the mean anomaly
M = w_orbit * (t + tp0);

% Estimate the true anomaly (assumes low eccentricity)
nu = M + 2*params.e*sin(M) + 1.25*params.e^2*sin(2*M);
% Define initial velocity vector
p = params.a*(1-params.e^2);
R = p/(1+params.e*cos(nu)); 
H = sqrt(mu*p);
phi = atan2(params.e*sin(nu),1+params.e*cos(nu));
lambda = (pi/2)-phi;
V = H/(R*cos(phi));
v1 = V*[cos(nu+lambda),sin(nu+lambda),0];

% Rotate about the ECI Z axis by the argument of perigee
cw = cos(params.w);
sw = sin(params.w);
v2 = [v1(1)*cw - v1(2)*sw, v1(1)*sw + v1(2)*cw, v1(3)];

% Rotate about the ECI X axis by the inclination
ci = cos(params.incl);
si = sin(params.incl);
v3 = [v2(1), v2(2)*ci - v2(3)*si, v2(2)*si + v2(3)*ci];

% Rotate about the ECI Z axis by the longitude of ascending node
co = cos(params.Omega);
so = sin(params.Omega);
v4 = [v3(1)*co - v3(2)*so, v3(1)*so + v3(2)*co, v3(3)];

% Set v = v4
v = v4;








