function [output, fs] = sp_eldar_impl(inp_fs, input, time_skew)
% Reconstruction of a signal from non-uniform samples
% Based on Sindhi and Prabhu's implementation of Eldar and Oppenheim's
% method

N = length(time_skew); % number of samplers
fs = inp_fs * N; % full sampling frequency

T_inp = 1/inp_fs;

% index_mapping is used to reorded filters in case the first input
% signal is actually delayed comparing to the second and not vice versa
[time_skew, index_mapping] = sort(time_skew);

TQ = 1; % Nyquist sampling period

% Decimation Periods - in our case all ADCs sample with the same rate
T = [3*TQ 3*TQ 3*TQ];

K = 0.5*lcm(2*T(1), 2*T(2))/TQ; % number of samples in recurrent period
K = 0.5*lcm(2*K, 2*T(3))/TQ;
capT = K*TQ; % the full sampling period - of all samplers
M = capT./T;
capM = lcm(M(1), M(2));
capM = lcm(capM, M(3));
ML = min(cellfun('length', input)); % number of slices

excess = ceil((K-1)/capM);
maxf = K/(excess*capM+1);
K1 = K/maxf;

taus = time_skew / T_inp * capT; % ADC delays in seconds
tausI = sort([taus(1) taus(2) taus(3)]);
tauI = zeros(K,ML);

for p = 1:K
    tauI(p,:) = tausI(p)+(0:ML-1)*capT;
end;

y = zeros(N,ML*K);
for p = 1:N
    x1 = input{index_mapping(p)};
    y1 = upsample(x1,K);
    
    % length of LF should be Multiple of LCM{M(p)}*2*K
    LFE = M(p)*capM*2*K1+1;
    nE = -(LFE-1)/2:1:(LFE-1)/2;
    h = sinc((nE/K)-(taus(p)/T(p))).*kaiser_mine1(LFE,3,-K*(taus(p)/T(p)));
    
    aaa = ones(1,M(p));
    bb = ones(M(p),LFE);
    for l = 1:M(p)
        for q = 1:N
            if q ~= p
                aaa(l) = aaa(l)*sin(pi*(taus(p)-taus(q)+(l-1)*T(p))/T(q));
                bb(l,:) = bb(l,:).*sin(pi*((nE*TQ/M(p))-taus(q)+(l-1)*T(p))/T(q));
            end;
        end;
        bb(l,:) = bb(l,:)/aaa(l);
    end;
    
    bbb = zeros(M(p),LFE);
    bbn = zeros(M(p),LFE);
    for m = 1:M(p)
        for l = 1:M(p)
            bbb(l,:) = bb(l,:)*exp(1i*(2*pi/M(p))*(m-1)*(l-1));
        end
        bbb = sum(bbb,1);
        bbn(m,:) = bbb.*exp(1i*(2*pi/M(p))*(m-1)*nE);
    end;
    bbn = sum(bbn,1);
    bbn = bbn.*h/M(p);
    
    y1 = conv(y1,bbn);
    delay = (length(h)-1)/2;
    y(p,:) = y1(1+delay:M(p):end-delay);
end

output = sum(real(y),1)';
end