function E = ShortTimeEnergy(signal, windowLength,step)
signal = signal / max(max(signal));
curPos = 1;
L = length(signal);
numOfFrames = floor((L-windowLength)/step) + 1;
%H = hamming(windowLength);
E = zeros(numOfFrames,1);
for (i=1:numOfFrames)
    window = (signal(curPos:curPos+windowLength-1));
    E(i) = (1/(windowLength)) * sum(abs(window.^2));
    curPos = curPos + step;
end
%Max = max(E);
%med = median(E);
%m = mean(E);
%a = length(find(E>2*med))/numOfFrames;
%b = length(find(E<(med/2)))/numOfFrames;

%S_EnergyM = length(find(E>2*med))/numOfFrames;
%S_EnergyV = length(find(E<(med/2)))/numOfFrames;
%S_EnergyM = std(E);
%S_EnergyV = a;