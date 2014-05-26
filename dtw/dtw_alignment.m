function [output] = dtw_alignment(samples, sr)
% Find minimum phase between samples using Dynamic Time Warping and
% interpolate using a phase vocoder
% samples - Samples array
% sr - Sampling rate
WINDOW = 512;
OVERLAP = 384;
num_sources = length(samples);

%     ml = min(cellfun('length', samples));

% Calculate STFT features for both sounds (25% window overlap)
D = cell(num_sources, 1);
for i = 1:num_sources
    D{i} = specgram(samples{i}, WINDOW, sr, WINDOW, OVERLAP);
end

% Construct the 'local match' scores matrix as the cosine distance
% between the STFT magnitudes
SM = simmx(abs(D{1}), abs(D{2}));

% Use dynamic programming to find the lowest-cost path between the
% opposite corners of the cost matrix
% Note that we use 1-SM because dp will find the *lowest* total cost
[p,q,C] = dp(1-SM);

% Bottom right corner of C gives cost of minimum-cost alignment of the two
%     min_cost_align = C(size(C,1),size(C,2));
% This is the value we would compare between different
% templates if we were doing classification.

% Calculate the frames in D2 that are indicated to match each frame
% in D1, so we can resynthesize a warped, aligned version
D2i1 = zeros(1, size(D{1}, 2));
for i = 1:length(D2i1)
    D2i1(i) = q(find(p >= i, 1));
end
% Phase-vocoder interpolate D2's STFT under the time warp
D2x = pvsample(D{2}, D2i1-1, WINDOW - OVERLAP);
% Invert it back to time domain
d2x = istft(D2x, WINDOW, WINDOW, WINDOW - OVERLAP);

% Warped version added to original target (have to fine-tune length)
% d2x = resize(d2x', length(samples{1}),1);
output = {samples{1}, d2x'};
end