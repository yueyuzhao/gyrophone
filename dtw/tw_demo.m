% DTW & CDTW example
% Sinusoidal signals temporal alignment

fs=125;
f1=1; A1=1;
f2=5; A2=0.8;
t1=0:1/fs:1/(2*f1);
t2=0:1/fs:2/(2*f2);
n1=(A1/10)*rand(size(t1));
n2=(A2/8)*rand(size(t2));
s1=A1*sin(2*pi*f1*t1)+n1; % 1st sinusoid with noise addition
s2=A2*sin(2*pi*f2*t2)+n2; % 2nd sinusoid with noise addition

figure; hold on;
plot(t1,s1,'b');
plot(t2,s2,'r');
grid;
xlabel('time (s)');
ylabel('amplitude (mV)');
title('Original disaligned waves');

pflag=1;

[dtw_Dist,D,dtw_k,w,s1w,s2w]=dtw(s1,s2,pflag);
dtw_Dist, dtw_k

[cdtw_Dist,D,cdtw_k,w,s1w,s2w]=cdtw(s1,s2,pflag);
cdtw_Dist, cdtw_k
