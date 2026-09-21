% Calculate visual magnitude of an object using equation in Shell paper
%
% 

function mvObj = CalculateVisualMagnitude_ShellUpdated(objDiameter,objReflectivity,objDistance,phaseAngle)

% Solar visual magnitude at 1 AU
mvSun = -26.73;

% Diffuse Phase angle factor - function relating illumination
phaseAngleFactor = ( 2 / ( 3 * pi ) ) * ( ( pi - phaseAngle ) * cos( phaseAngle ) + sin( phaseAngle ) ); 

% Object visual magnitude
%mvObj = mvSun - 2.5 * log10( (( objReflectivity * objDiameter ^ 2 ) / (4 * objDistance ^ 2)) *(1/4+phaseAngleFactor) ); 

%Assuming diffuse reflection alone
mvObj = mvSun - 2.5 * log10( (( objReflectivity * objDiameter ^ 2 ) / (4 * (objDistance * 10e3) ^ 2)) *(phaseAngleFactor) ); 
%if objDistance<550
    %objDistance
    %phaseAngleFactor
    %mvObj
%end