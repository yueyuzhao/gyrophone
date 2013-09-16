function [p,q,D] = dp2(M)
% [p,q] = dp2(M) 
%    Use dynamic programming to find a min-cost path through matrix M.
%    Return state sequence in p,q
%    This version has limited slopes [2/1] .. [1/2]
% 2003-03-15 dpwe@ee.columbia.edu

% Copyright (c) 2003 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT

[r,c] = size(M);

% costs
D = zeros(r+1, c+1);
D(1,:) = NaN;
D(:,1) = NaN;
D(1,1) = 0;
D(2:(r+1), 2:(c+1)) = M;

% traceback
phi = zeros(r+1,c+1);

for i = 2:r+1; 
  for j = 2:c+1;
    % Scale the 'longer' steps to discourage skipping ahead
    kk1 = 2;
    kk2 = 1;
    dd = D(i,j);
    [dmax, tb] = min([D(i-1, j-1)+dd, D(max(1,i-2), j-1)+dd*kk1, D(i-1, max(1,j-2))+dd*kk1, D(i-1,j)+kk2*dd, D(i,j-1)+kk2*dd]);
    D(i,j) = dmax;
    phi(i,j) = tb;
  end
end

% Traceback from top left
i = r+1; 
j = c+1;
p = i;
q = j;
while i > 2 & j > 2
  tb = phi(i,j);
  if (tb == 1)
    i = i-1;
    j = j-1;
  elseif (tb == 2)
    i = i-2;
    j = j-1;
  elseif (tb == 3)
    j = j-2;
    i = i-1;
  elseif (tb == 4)
    i = i-1;
    j = j;
  elseif (tb == 5)
    j = j-1;
    i = i;
  else    
    error;
  end
  p = [i,p];
  q = [j,q];
end

% Strip off the edges of the D matrix before returning
D = D(2:(r+1),2:(c+1));

% map down p and q
p = p-1;
q = q-1;
