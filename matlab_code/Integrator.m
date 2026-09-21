

function [t,z] =  Integrator(z0, tspan)
mu = 3.985992e+5;   
% rE = 6.378e+3;
% %b =  params.bstar/rE; 
% density_ratio = 0.17; %.38
% 
% % Orbit rate
% w_orbit = sqrt(mu/params.a^3);
% w_orbit;
% 
% % Determine the initial eccentric anomaly and the initial time since periapsis passage
% TA = params.nu0 + (2*params.e*sin(params.nu0));
% E0 = acos((params.e+cos(TA))/(1+params.e*cos(TA)));
% if TA > pi
%     E0 = 2*pi - E0;   % Correct for the right quadrant
% end
% tp0 = (E0 - params.e*sin(E0))/w_orbit;
% 
% % Determine the mean anomaly
% M = w_orbit * tp0;
% 
% % Estimate the true anomaly (assumes low eccentricity)
% nu = M + 2*params.e*sin(M) + 1.25*params.e^2*sin(2*M);
% 
% % Define initial position vector
% p = params.a*(1-params.e^2);
% R = p/(1+params.e*cos(nu));
% %delR = (b* velocity^2/w_orbit)*100;
% %R = R-delR;
% r = [R*cos(nu) R*sin(nu) 0];
% 
% % Rotate about the ECI Z axis by the argument of perigee
% cw = cos(params.w);
% sw = sin(params.w);
% r = [r(1)*cw - r(2)*sw, r(1)*sw + r(2)*cw, r(3)];
% %Rw = [cos(w) -sin(w) 0; sin(w) cos(w) 0; 0 0 1];
% 
% % Rotate about the ECI X axis by the inclination
% ci = cos(params.incl);
% si = sin(params.incl);
% r = [r(1), r(2)*ci - r(3)*si, r(2)*si + r(3)*ci];
% 
% % Rotate about the ECI Z axis by the longitude of ascending node
% co = cos(params.Omega);
% so = sin(params.Omega);
% r = [r(1)*co - r(2)*so, r(1)*so + r(2)*co, r(3)];
% 
% V = params.mm*240*2*pi*(sqrt(sum(r.^2)))/(60*60*24);
% V;
% %H = sqrt(mu*p);
% phi = atan2(params.e*sin(nu),1+params.e*cos(nu));
% lambda = (pi/2)-phi;
% %V = H/(R*cos(phi));
% v1 = V*[cos(nu+lambda),sin(nu+lambda),0];
% 
% % Rotate about the ECI Z axis by the argument of perigee
% cw = cos(params.w);
% sw = sin(params.w);
% v2 = [v1(1)*cw - v1(2)*sw, v1(1)*sw + v1(2)*cw, v1(3)];
% 
% % Rotate about the ECI X axis by the inclination
% ci = cos(params.incl);
% si = sin(params.incl);
% v3 = [v2(1), v2(2)*ci - v2(3)*si, v2(2)*si + v2(3)*ci];
% 
% % Rotate about the ECI Z axis by the longitude of ascending node
% co = cos(params.Omega);
% so = sin(params.Omega);
% v4 = [v3(1)*co - v3(2)*so, v3(1)*so + v3(2)*co, v3(3)];
% 
% % Set v = v4
% v = v4;

%r = [1-e;0;0];
%v = [0;0;sqrt((1+e)/(1-e))];
%tspan = [0 0.1];
%velocity = sqrt(sum(v.^2));

%z0=[r(1);r(2);r(3);-v(1);-v(2);-v(3)]; %x, y, z, vx, vy, vz
%z0 = z; %[3829.45, -888.41, 5459.13, 2.5396, 7.2434, -0.6063];
%options = odeset('RelTol',1e-4,'AbsTol',1e-6);
%tspan = [0, 1000, 2000];
% [P, a] = computeOrbitalDecay(params.a, params.e, tspan(2)-tspan(1));
% a
% r = (z0(1)^2 + z0(2)^2 + z0(3)^2)^(1/2)
if nargin == 0
    tspan=[0 100000];
    z0 = [3829.45, -888.41, 5459.13, 2.5396, 7.2434, -0.6063];
    [t,z] = Integrator(z0, tspan);
    return;
end
try
[t,z] = ode78(@twobodyf, tspan, z0);
catch
warning("Decayed.")
end
%z;
f1 = figure();
plot3(z(:,1),z(:,2), z(:,3));
xlabel("x (km)");
ylabel("y (km)");
zlabel("z (km)");
% saveas(f1, "Orbit plot "+params.mm+".jpg");
%f1.Visible="off";
%close(f1);
%axis equal
%b;
function dz = twobodyf(t,z)
    dz = zeros(6,1);
    mu = (3.985992e+5); 
    %[P, a] = computeOrbitalDecay(params.a, params.e, tspan(2)-tspan(1));
    r = (z(1)^2 + z(2)^2 + z(3)^2)^(1/2);
    %params.a = a;


    %r^(1/3)
    %delR = r-a;
    %r = r - delR;
    %a_a = b * velocity^2; 
    %M = w_orbit *(t+tp0);

    % Estimate the true anomaly (assumes low eccentricity)
    %nu = M + 2*params.e*sin(M) + 1.25*params.e^2*sin(2*M);

    %delr = [delR*cos(nu) delR*sin(nu) 0];
    %delr = [delr(1)*cw - delr(2)*sw, delr(1)*sw + delr(2)*cw, delr(3)];
    %delr = [delr(1), delr(2)*ci - delr(3)*si, delr(2)*si + delr(3)*ci];
    %delr = [delr(1)*co - delr(2)*so, delr(1)*so + delr(2)*co, delr(3)];
    %delr;
    r3 = r^3;
    alpha= mu/r3;
    dz(1) = z(4); %-(z(1)/abs(z(1)))*delr(1); %-(z(1)/abs(z(1)))*(density_ratio*b* 2*z(4)^2/w_orbit);
    dz(2) = z(5); %-(z(2)/abs(z(2)))*delr(2); %-(z(2)/abs(z(2)))*(density_ratio*b* 2*z(5)^2/w_orbit);
    dz(3) = z(6); %-(z(3)/abs(z(3)))*delr(3); %-(z(3)/abs(z(3)))*(density_ratio*b* 2*z(6)^2/w_orbit);
    dz(4) = -alpha*(z(1)); % - (z(1)/abs(z(1)))*delr(1)); %-0.5*density_ratio*b*z(4)*abs(z(4));
    dz(5) = -alpha*(z(2)); % - (z(2)/abs(z(2)))*delr(2)); %-0.5*density_ratio*b*z(5)*abs(z(5)); %-(z(5)/abs(z(5)))*density_ratio*b*z(5)^2;
    dz(6) = -alpha*(z(3)); % - (z(3)/abs(z(3)))*delr(3)); %-0.5*density_ratio*b*z(6)*abs(z(6)); %-(z(6)/abs(z(6)))*density_ratio*b*z(6)^2;
    %if r3^(1/3) <= (rE+40)
        %dz(1) = 0;
        %dz(2) = 0;
        %dz(3) = 0;
        %dz(4) = -z(4);
        %dz(5) = -z(5);
        %dz(6) = -z(6);
    %end
    
end


end







% for i=2:N+1
%     alpha=mu/(x(i-1).^2 + y(i-1).^2).^(3/2);
%     u(i)=u(i-1)-h*alpha*x(i-1);
%     v(i)=v(i-1)-h*alpha*y(i-1);
%     x(i)=x(i-1)+h*u(i-1);
%     y(i)=y(i-1)+h*v(i-1);
%     t(i)=t(i-1)+h;
% end