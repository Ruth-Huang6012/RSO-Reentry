function [P, R] = computeOrbitalDecay(a,e, bstar,dt)
mu = 3.985992e+5;   
rE = 6.378e+3;
m0 = 10;                             %kg
A =  1; 
Ap = 0;
F107 = 70;
Cd = bstar*2*m0/(0.000012*A);
Cd;
% if nargin == 0
%        a =  rE+300;                 %km
%        a
%        m0 = 100;                             %kg
%        A =  1;                               %m^2
%        e =  0;
%        Cd = 1;
%      F107 = 70;
%        Ap = 0;
%        dt = 8000;
%     [P] = computeOrbitalDecay(a,e,A,Cd,m0,F107,Ap, dt);
%     return;
% end

P = 2*pi.*sqrt(a.^3./mu);  %Orbital Period (sec)P
Ae = A.*Cd;                %Effective Cross Sectional Area
dt = dt;           %Time step in seconds
t = 0;                     %Elapsed Propagation Time (sec)

%% Defined inline Orbital Routines:
 h = @(P)((P./(2.*pi)).^2.*mu).^(1/3)-rE;   % Compute the circular height (km)
 rP = @(a,e)a.*(1-e);                        % Compute the Perigee Radius calculation
 he = @(a,e)(rP(a,e)-rE)+900.*e.^(0.6);      % Compute the effective height (km)
 
 %% Very Basic Atmospheric Model:
 m = @(h)27-0.012.*(h-200);                        %180 < h [km] < 500
 H = @(h)(900 + 2.5.*(F107-70) + 1.5.*Ap)./m(h);   %Equivilent height in km
 rho = @(h)6e-10.*exp(-(h-175)./H(h));             %Density (kg m^-3)
 %% Find the period corresponding to a height of 180 km:
 %P_min = 2*pi.*sqrt((Re+180).^3./Mu);

 %Iterate satellite orbit with time:
 %while any(P(end,:) > P_min,2)
 hh = he(h(P)+rE,e);
     %idx = hh >= 180;
     %Compute the change in orbital period:
 dP = bsxfun(@rdivide,-3.*pi.*(hh+rE)*1000.*rho(hh).*Ae.*dt,m0);
 %P(end+1,idx) = P(end,idx)+dP(idx); %#ok<AGROW>     
 %t(end+1,1) = t(end,1)+dt;   %#ok<AGROW>
 %end
 
%Clean-up the results such that the period does not fall below P_min:
%P(P<P_min) = NaN;
P = P+dP;
P;
R = ((P./(2.*pi)).^2.*mu).^(1/3);
R;
end