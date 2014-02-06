% Eldar reconstruction

N = 2;                  % Nth order nonuniform sampling
TQ = 1;Fs = 1/TQ;                 % Nyquist Period    

T = [1.5*TQ 3*TQ];      % Decimation Periods
K = 0.5*lcm(2*T(1), 2*T(2))/TQ; % number of samples in recurrent period
capT = K*TQ; % the full sampling period - of all samplers
M = capT./T;
ML = 400; % number of slices
w_c = 0.85;
NS = 100;  % Number of Sinusoids

LF = lcm(M(1),M(2))*2*K+1;      % length of LF should be Multiple of LCM{M(p)}*2*K
n = -(LF-1)/2:1:(LF-1)/2;
Hd = firpm(LF-1,[0 w_c],[0 w_c*pi],'differentiator');
delayV = (LF-1)/2;

k = -(K-1):1:(K-1);
m = (0:1:(2*K-1))';
F = exp(1i*(pi/K).*kron(m,k));
std = [1e-6 1e-5 1e-4 1e-3 1e-2 1e-1];%5*1e-1];

serE = zeros(size(std));

MCruns = 25;
MCruns1 = 25;

for tt = 1:length(std)
    aa = 0;
    display(tt);
    for rrr = 1:MCruns1
        for pp = 1:MCruns;
            Frq = rand(1,NS)*w_c/2;
            Amp = rand(1,NS)/(sqrt(NS)*2);
            Phi = rand(1,NS)*2*pi;
            input = zeros(1,ML*K);
            for k = 1:NS
              input = input + Amp(k)*sin(2*pi*Frq(k)*(0:ML*K-1)*TQ+Phi(k));
            end
        end
        
        taus = [0 1+std(tt)*randn]*TQ;    
        if or(taus(2)==1.5*TQ,taus(1)==taus(2))
            aa = aa+1;
            continue;
        end
        tausI = sort([taus(1) taus(2) T(1)+taus(1)]);
        tauI = zeros(K,ML);
        for p = 1:K
            tauI(p,:) = tausI(p)+(0:ML-1)*capT;
        end;
        a = zeros(1,K);
        for p = 1:K
            a(p) = 1;
            for q = 1:K
                if q ~= p
                        a(p) = a(p)/sin(pi*(tausI(p)-tausI(q))/capT);
                end;
            end;
        end;

        y = zeros(N,ML*K);
        for p = 1:N
            tau = taus(p)+(0:ML*M(p)-1)*T(p);
            x1 = zeros(1,ML*M(p));
            for k = 1:NS
                x1 = x1 + Amp(k)*sin(2*pi*Frq(k)*tau+Phi(k));
            end;
            y1 = upsample(x1,K);

            LFE = M(p)*lcm(M(1),M(2))*2*K+1;      % length of LF should be Multiple of LCM{M(p)}*2*K
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
        end;
        y = sum(real(y),1);
        x = input;
        y = y(160:end-60);
        x = x(160:end-60);
        serE(tt) = serE(tt)+20*log10(norm(x,2)/norm(y-x,2));
    end
end

serE = serE/(MCruns*(MCruns1-aa));

plot(std,serE);
xlabel('Standard Deviation (\sigma)','fontsize',14,'fontweight','b');
ylabel('SNR in dB','fontsize',14,'fontweight','b');
grid on;box on;
set(gca,'fontsize',14,'fontweight','b')