function [ u ] = UnitVector( v )
% this function is used to get unit vector
%% Coded by
% Mohamed Mohamed El-Sayed Atyya
% mohamed.atyya94@eng-st.cu.edu.eg
%% inputs:
% v : the vector
%% outputs:
% u : the unit vector of vector v 
% -----------------------------------------------------------------------------------------------------------------------------------------------------------
u=v/norm(v);
end