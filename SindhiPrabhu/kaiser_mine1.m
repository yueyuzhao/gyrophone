function w = kaiser_mine1(n_est,bta,d)
%KAISER Kaiser window.
%   W = KAISER(N) returns an N-point Kaiser window in the column vector W.
% 
%   W = KAISER(N,BTA) returns the BETA-valued N-point Kaiser window.
%       If omitted, BTA is set to 0.500.
%
%   See also CHEBWIN, GAUSSWIN, TUKEYWIN, WINDOW.

%   Author(s): L. Shure, 3-4-87
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.17.4.4 $  $Date: 2007/12/14 15:05:16 $

% error(nargchk(1,2,nargin,'struct'));
% 
% % Default value for the BETA parameter.
% if nargin < 2 || isempty(bta), 
%     bta = 0.500;
% end

% [nn,w,trivialwin] = check_order(n_est);
% if trivialwin, return, end;

% nw = round(nn)
nw = n_est;
bes = abs(besseli(0,bta));
odd = rem(nw,2);
xind = ((nw-1)/2)^2;
% n = fix((nw+1)/2)
% n = nw-1;
xi = (0:nw-1) + .5*(1-odd)+d-((nw-1)/2);
xi = xi.^2;
w = besseli(0,bta*sqrt(1-xi/xind))/bes;
% w = abs([w(n:-1:odd+1) w])'

    
% [EOF] kaiser.m
