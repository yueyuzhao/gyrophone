% Eldar reconstruction

N = 3;                  % Nth order nonuniform sampling
TQ = 1;                 % Nyquist Period    
L=20;                   % Resolution factor for fraction delay

T = [2*TQ 3*TQ 6*TQ];      % Decimation Periods
K = 0.5*lcm(2*T(1), 2*T(2)); K = 0.5*lcm(2*K, 2*T(3))/TQ;
capT = K*TQ; M = capT./T;
capM = lcm(M(1), M(2)); capM = lcm(capM, M(3));
excess = ceil((K-1)/capM);
maxf = K/(excess*capM+1);
TQ1 = maxf*TQ;
K1 = K/maxf;

ML = 400; % number of slices
w_c = 0.85;
NS = 100;  % Number of Sinusoids

LF = capM*2*K1+1;  %359,159,239          % min length of LF should be capM*2*K1
n = -(LF-1)/2:1:(LF-1)/2;
Hd = firpm(LF-1,[0 w_c],[0 w_c*pi],'differentiator');
delayV = (LF-1)/2;


std = [1e-6 1e-5 1e-4 1e-3 1e-2 1e-1];%5*1e-1];

serE = zeros(size(std));

MCruns = 25;
MCruns1 = 25;

for tt = 1:length(std)
    aa = 0;
    display(tt);
    for rrr = 1:MCruns1
        taus = [0 1.1+std(tt)*randn 2.2+std(tt)*randn]*TQ;    
        if or(taus(2)==TQ,or(taus(2)==2*TQ,or(taus(3)==2*TQ,or(taus(2)==taus(3),taus(2)==taus(1)))))
            aa = aa+1;
            display(taus);
            continue;
        end
        
        tausI = sort([taus(1) taus(2) taus(3) T(1)+taus(1) T(2)+taus(2) 2*T(1)+taus(1)]);
        a = zeros(1,K);
        for p = 1:K
            a(p) = 1;
            for q = 1:K
                if q ~= p
                        a(p) = a(p)/sin(pi*(tausI(p)-tausI(q))/capT);
                end;
            end;
        end;
        
        for pp = 1:MCruns;
            Frq = rand(1,NS)*w_c/2;
            Amp = rand(1,NS)/(sqrt(NS)*2);
            Phi = rand(1,NS)*2*pi;
            inputN = zeros(1,ML*K1);
            input = zeros(1,ML*K);
            for k = 1:NS
              inputN = inputN + Amp(k)*sin(2*pi*Frq(k)*(0:ML*K1-1)*TQ1+Phi(k));
              input = input + Amp(k)*sin(2*pi*Frq(k)*(0:ML*K-1)*TQ+Phi(k));
            end;
        end
        
        y = zeros(N,ML*K1);
        for p = 1:N
            tau = taus(p)+(0:ML*M(p)-1)*T(p);
            x1 = zeros(1,ML*M(p));
            for k = 1:NS
                x1 = x1 + Amp(k)*sin(2*pi*Frq(k)*tau+Phi(k));
            end;

            y1 = upsample(x1,K1);

            LFE = M(p)*capM*2*K1+1;  %359,159,239          % min length of LF should be capM*2*K1
            nE = -(LFE-1)/2:1:(LFE-1)/2;
            h = sinc((nE/K1)-(taus(p)/T(p))).*kaiser_mine1(LFE,18,-K1*(taus(p)/T(p)));
            aaa = ones(1,M(p));
            bb = ones(M(p),LFE);
            for l = 1:M(p)
                for q = 1:N
                    if q ~= p
                        aaa(l) = aaa(l)*sin(pi*(taus(p)-taus(q)+(l-1)*T(p))/T(q));
                        bb(l,:) = bb(l,:).*sin(pi*((nE*TQ1/M(p))-taus(q)+(l-1)*T(p))/T(q));
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

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            y1 = conv(y1,bbn);
            delay = (length(h)-1)/2;
            y1 = y1(1+delay:M(p):end-delay);
            y(p,:) = y1;
        end;
        y = real(sum(y,1));
        x = inputN;
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