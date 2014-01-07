function C = SpectralCentroid(signal,windowLength, step, fs)

% function C = SpectralCentroid(signal,windowLength, step, fs)
% 
% This function computes the spectral centroid feature of an audio signal
% ARGUMENTS:
%  - signal: the audio samples
%  - windowLength: the length of the window analysis (in number of samples)
%  - step: the step of the window analysis (in number of samples)
%  - fs: the sampling frequency
% 
% RETURNS:
%  - C: the sequence of the spectral centroid feature
%

signal = signal / max(abs(signal));
curPos = 1;
L = length(signal);
numOfFrames = floor((L-windowLength)/step) + 1;
H = hamming(windowLength);
m = ((fs/(2*windowLength))*[1:windowLength])';
C = zeros(numOfFrames,1);
for (i=1:numOfFrames)
    window = H.*(signal(curPos:curPos+windowLength-1));    
    FFT = (abs(fft(window,2*windowLength)));
    FFT = FFT(1:windowLength);  
    FFT = FFT / max(FFT);
    C(i) = sum(m.*FFT)/sum(FFT);
    if (sum(window.^2)<0.010)
        C(i) = 0.0;
    end
    curPos = curPos + step;
end
C = C / (fs/2);