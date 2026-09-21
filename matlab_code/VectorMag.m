% Mag = VectorMag(vectors,dim)
%
% Calculates the magnitudes of a list of 3D vectors.
%
% Inputs:
%   vectors - an Mx3 or 3xN list of vectors
%   dim     - dimension of matrix along which vectors lie: 
%               1 for horizontal vectors stacked vertically (Mx3)
%               2 for vertical vectors stacked horizontally (3xN)
%             If no input is given, then it is assumed to be Mx3
%
% Outputs:
%   mag     - an Mx3 or 3xN list of vector magnitudes

function [mag] = VectorMag(vectors,varargin)

[nRows,nCols] = size(vectors);

if nargin == 1
  
  % Horizontal vectors
  if nCols > nRows
    mag = sqrt( vectors * vectors' );
  else
    mag = sqrt( vectors' * vectors );
  end

else
  
  dim = varargin{1};

  % Horizontal vectors
  if dim == 1
    mag = zeros(nRows,1);
    for i=1:nRows
      mag(i) = sqrt( vectors(i,:) * vectors(i,:)' );
    end
  end

  % Vertical vectors
  if dim == 2    
    mag = zeros(1,nCols);
    for i=1:nCols
      mag(i) = sqrt( vectors(:,i)' * vectors(:,i) );
    end
  end

end