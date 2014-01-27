function A = resize(B,R,C)
% A = resize(B,R,C)   Crop or zero-pad B to have R rows and C columns.
%	I'm sure this must already be provided, but how to know?
% dpwe 1995jan21

% Copyright (c) 1995 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT

A = zeros(R,C);
[r,c] = size(B);

mr = min(r,R);
mc = min(c,C);

A(1:mr,1:mc) = B(1:mr, 1:mc);

