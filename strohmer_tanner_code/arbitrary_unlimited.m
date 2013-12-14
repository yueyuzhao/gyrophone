%THIS CODE IS ONLY FOR THE JUST BARELY OVERSAMPLES, I.E., n=ceil(over_r)
%THE MORE GENERAL CODE IS arbitrary_over.m
begin=clock;
omega=1;
over_r=1.2;
n=ceil(over_r);%this is the number of unions of sets, should be the ceil(over_r)
p=n+1; %this is the degree of the fine mesh, use p=n+1, or larger
L=200/n %the signal is sampled from -L*T:L*T

%I have doubled over_r and halved L so that the 
%interval is the same, i.e., width is the same 
%as it was for the single sample case.

step=over_r/2/omega;
rand('state',sum(100*clock)) 
%rand('seed',4)
h=(rand(n,1)-1/2)*step;

width=L*step;
y=-width:step/p:width;
ysize=size(y);
ysize=ysize(2);
% y is the sampling set for signal_origin and y+h for signal_shift
signal=zeros(n,ysize);
pad=zeros(n,ysize);

signal_origin=zeros(size(y));
signal_shift=zeros(size(y));
pad_origin=zeros(size(y));
pad_shift=zeros(size(y));

%rand('seed',0) 
%this sets the seed to a fixed value, 0, so that I get reproducable results
rand('state',sum(100*clock))
R=100;
%the first two collumns are the amplitudes, real(first) and complex(second),
%i.e., signal_coef(1,q)+i*signal_coef(2,q), the third and fourth are the
%band limits, for example, min(signal_coef(3,q),signal_coef(4,q)) is 
%the left bandwidth, the max will give the right bandwidth 
signal_coef=rand(4,R);
signal_coef(1,:)=2*(signal_coef(1,:)-1/2);
signal_coef(1,:)=signal_coef(1,:)/norm(signal_coef(1,:),2)/2/pi;
signal_coef(2,:)=2*(signal_coef(2,:)-1/2);
signal_coef(2,:)=signal_coef(2,:)/norm(signal_coef(2,:),2)/2/pi;
signal_coef(3,:)=2*(signal_coef(3,:)-1/2);
signal_coef(3,:)=omega*signal_coef(3,:)/max(abs(signal_coef(3,:)));
signal_coef(4,:)=2*(signal_coef(4,:)-1/2);
signal_coef(4,:)=omega*signal_coef(4,:)/max(abs(signal_coef(4,:)));



%need an axis for the dual space that has the same number of
%elements as y does.  

dual_axis=2*p*omega/over_r/(2*p*L+1)*(-p*L:1:p*L);

sample_dual=zeros(size(dual_axis));
dualsize=size(dual_axis); 
dualsize=dualsize(2);

for q=1:R
  for j=1:dualsize
if dual_axis(j)>=min(signal_coef(3,q),signal_coef(4,q)) & dual_axis(j)<=max(signal_coef(3,q),signal_coef(4,q))
      sample_dual(j)=sample_dual(j)+signal_coef(1,q)+i*signal_coef(2,q);
    end
  end
end


tmp=0;
for q=1:R 
  signal_origin=signal_origin+(signal_coef(1,q)+i*signal_coef(2,q))./(sqrt(2*pi)*2*pi*i*y).*(exp(2*pi*i*y*max(signal_coef(3,q),signal_coef(4,q)))-exp(2*pi*i*y*min(signal_coef(3,q),signal_coef(4,q))))*2*pi;
%  signal_shift=signal_shift+(signal_coef(1,q)+i*signal_coef(2,q))./(sqrt(2*pi)*2*pi*i*(y+h(2))).*(exp(2*pi*i*(y+h(2))*max(signal_coef(3,q),signal_coef(4,q)))-exp(2*pi*i*(y+h(2))*min(signal_coef(3,q),signal_coef(4,q))))*2*pi;
  tmp=tmp+(signal_coef(1,q)+i*signal_coef(2,q))*(max(signal_coef(3,q),signal_coef(4,q))-min(signal_coef(3,q),signal_coef(4,q)))/sqrt(2*pi)*2*pi;
end
  joe=0;
  for q=1:ysize
    if y(q)==0
      joe=q;
    end
  end
  if joe>0
    signal_origin(joe)=tmp;
  end

for j=1:n
tmp=0;
for q=1:R 
  signal(j,:)=signal(j,:)+(signal_coef(1,q)+i*signal_coef(2,q))./(sqrt(2*pi)*2*pi*i*(y+h(j))).*(exp(2*pi*i*(y+h(j))*max(signal_coef(3,q),signal_coef(4,q)))-exp(2*pi*i*(y+h(j))*min(signal_coef(3,q),signal_coef(4,q))))*2*pi;
  tmp=tmp+(signal_coef(1,q)+i*signal_coef(2,q))*(max(signal_coef(3,q),signal_coef(4,q))-min(signal_coef(3,q),signal_coef(4,q)))/sqrt(2*pi)*2*pi;
end
  joe=0;
  for q=1:ysize
    if y(q)+h(j)==0
      joe=q;
    end
  end
  if joe>0
    signal(j,joe)=tmp;
  end
end


% p=n is the measure of difference between the fine and coarse mesh
for j=1:p:ysize
  pad(:,j)=signal(:,j);
end

pad_dual=zeros(n,ysize);

for j=1:dualsize
  for k=1:n
    pad_dual(k,j)=sum(pad(k,:).*exp(-2*pi*i*dual_axis(j)*y));
  end
end

pad_dual=pad_dual*(over_r/2/omega/p)/sqrt(2*pi);

%SHOULD THEY BE MULTIPLIED BY p SO THAT THEY MATCH sample_dual?

%this makes it so that the origin matches.
for j=1:n
  pad_dual(j,:)=pad_dual(j,:).*exp(-2*pi*i*h(j)*dual_axis);
end


A=zeros(n);
R=zeros(n);
for j=1:n
  for k=1:n
    A(j,k)=exp(2*pi*i*h(k)*j/step);
  end
R(:,j)=exp(2*pi*i*h*(j-n-1)/step); 
end
A_inverse=inv(A);

c=zeros(n);

for k=1:n
e=zeros(n,1);
e(n-k+1)=1;
R_k=diag(R(:,k));
c(k,:)=(inv(R_k)*A_inverse*e)'; %'
end



partition=partitions(omega,over_r,dual_axis);


filters=zeros(n,length(dual_axis));
for j=1:n
  for k=1:n
    filters(j,:)=filters(j,:)+c(k,j)*partition(k,:);
  end
end

filtered_duals=zeros(size(filters));

for j=1:n
  filtered_duals(j,:)=filtered_duals(j,:)+filters(j,:).*pad_dual(j,:);
end

recon_dual=zeros(size(dual_axis));
for j=1:n
  recon_dual=recon_dual+filtered_duals(j,:);
end


recon_signal=zeros(size(y));

k=-p*L:1:p*L;

for j=1:dualsize
  recon_signal=recon_signal+recon_dual(j)*exp(2*pi*i*k/(2*p*L+1)*k(j));
end

recon_signal=recon_signal/(2*p*L+1)*sqrt(2*pi)*omega*p/over_r*2*p;

semilogy(y,abs(recon_signal-signal_origin),'k');
h/step
cond(A)

done=clock;
time_cost=done-begin;
time_cost=time_cost(6)+60*time_cost(5)+360*time_cost(4)


