function [output, fs] = sp_johansson_impl(inp_fs, input, time_skew)
% Reconstruction of a signal from non-uniform samples
% Based on Sindhi and Prabhu's implementation of Johansson's
% method

% index_mapping is used to reorded filters in case the first input
% signal is actually delayed comparing to the second and not vice versa
N = length(time_skew); % number of samplers
fs = inp_fs * N; % full sampling frequency

T_inp = 1/inp_fs;

% index_mapping is used to reorded filters in case the first input
% signal is actually delayed comparing to the second and not vice versa
[time_skew, index_mapping] = sort(time_skew);
x11 = cell2mat(input')';
x11 = x11(index_mapping, :);

TQ = 1; % Nyquist sampling period

% Decimation Periods - in our case all ADCs sample with the same rate
T = [2*TQ 2*TQ];

K = 0.5*lcm(2*T(1), 2*T(2))/TQ; % number of samples in recurrent period
capT = K*TQ; % the full sampling period - of all samplers
M = capT./T;

ML = min(cellfun('length', input)); % number of slices
w_c = 0.85;

LF = lcm(M(1), M(2))*2*K+1;  %% min length of LF should be capM*2*K1
n = -(LF-1)/2:1:(LF-1)/2;

taus = time_skew / T_inp * capT; % ADC delays in seconds
tausI = sort([taus(1) taus(2)]);
tauI = zeros(K,ML);
for p = 1:K
    tauI(p,:) = tausI(p)+(0:ML-1)*capT;
end;

r = tausI-TQ*(0:K-1);
r = r.';
w_o = w_c*pi*TQ;
hJ = zeros(K,LF);
Nt = (LF-1)/2;
for i = 1:K
    C = -2*sin(w_o*(n-r(1+(mod(i-1-n,K)))'))./(pi*(n-r(1+(mod(i-1-n,K)))'));
    C(isnan(C))=-2*w_o/pi;
    C = C.';
    S = zeros(LF,LF);
    for k = 1:LF
        S(k,:) = sin(w_o*(-Nt+k-1-r(1+(mod(i-1-(-Nt+k-1),K)))-(n-r(1+(mod(i-1-n,K)))')))./(pi*(-Nt+k-1-r(1+(mod(i-1-(-Nt+k-1),K)))-(n-r(1+(mod(i-1-n,K)))')));
    end;
    S(isnan(S))=w_o/pi;
    hJ(i,:) = -0.5*S\C;
end;

x1 = reshape(x11,1,size(x11,2)*K);
y1 = zeros(K,length(x1));
for j=1:K
    y1(j,:) = filter(hJ(j,:),1,x1);
    y1(j,:) = upsample(downsample(y1(j,:),K,j-1),K)/K;
    y1(j,:) = filter([zeros(1,j-1),1],1,y1(j,:));
end;
y = K*0.25*sum(y1,1);
delayJ = (size(hJ,2)-1)/2;
y = real(y(1+delayJ:end));

output = y;
end