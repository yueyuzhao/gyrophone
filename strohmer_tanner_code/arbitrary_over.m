begin=clock;
omega=1;
over_r=2.4; %note that over_r should be between 3 and 4 for this program.
rate=5.3; %this is approximatly the ratio N/r, here the ratio must be above 1
n=ceil(rate*over_r);%this is the number of unions of sets
p=ceil(2*n-over_r); %this is the degree of the fine mesh, use p=n+1, or larger
L=200/n; %the signal is sampled from -L*T:L*T
%L=0.5;
step=over_r/2/omega;



%R1=round(-2/3+n/3);
%L1=R1+1-n;
%L2=round(2/3-n/3);
%R2=n+L2-1;

%I have doubled over_r and halved L so that the 
%interval is the same, i.e., width is the same 
%as it was for the single sample case.

rand('state',sum(100*clock)) 
%rand('seed',4)
h=(rand(n,1)-1/2)*step;
%h=(-1/2:1/n:1/2-1/n)*step;

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

kappa=max(2,min(n,floor((n+over_r+1)/(n-over_r+1))))

%b=zeros(2*kappa,1);
%B=zeros(2*kappa);
%B(1,1)=1; B(1,2)=1; B(1,3)=-1;
%B(kappa,end)=1; B(kappa,end-1)=1; B(kappa,end-2)=-1;
%
%for j=2:kappa-1
%  B(j,2*(j-1))=-1;
%  B(j,2*(j-1)+1)=1;
%  B(j,2*(j-1)+2)=1;
%  B(j,2*(j-1)+3)=-1;
%end
%b(1)=-1;
%b(kappa)=1;
%for j=1:kappa
%  B(j+kappa,2*j-1)=-1;
%  B(j+kappa,2*j)=1;
%  b(j+kappa)=n-1;
%end
%tmp1=B\b;

zones=zeros(kappa,2);
for j=1:kappa
%zones(j,1)=tmp1(2*j-1);
%zones(j,2)=tmp1(2*j);
zones(j,1)=round(j*(n+1)/(kappa+1)-n);
zones(j,2)=zones(j,1)+n-1;
end


%for j=1:kappa
%  if abs(zones(j,1)-round(zones(j,1)))<=abs(zones(j,2)-round(zones(j,2)))
%    zones(j,1)=round(zones(j,1));
%    zones(j,2)=n-1+zones(j,1);
%  else
%    zones(j,2)=round(zones(j,2));
%    zones(j,1)=zones(j,2)-n+1;
%  end
%end

A=zeros(n);
for j=1:n
  for k=1:n
    A(j,k)=exp(2*pi*i*h(k)*j/step);
  end
end
A_inverse=inv(A);

c=zeros(kappa,n);

for j=1:kappa
  e=zeros(n,1);
  e(1-zones(j,1))=1;
  R=diag(exp(2*pi*i*h*(zones(j,1)-1)/step));
  c(j,:)=(inv(R)*A_inverse*e)'; %'
end

%e=zeros(n,1);
%e(1-L2)=1;
%R=diag(exp(2*pi*i*h*(L2-1)/step));
%c(2,:)=(inv(R)*A_inverse*e)'; %'



partition=over_partitions(zones,omega,over_r,n,dual_axis);


%left_partition=zeros(size(dual_axis));
%right_partition=zeros(size(dual_axis));

%for j=1:length(dual_axis)
%  if dual_axis(j)<=(L1-1)/step+omega
%    left_partition(j)=0;
%  elseif (L1-1)/step+omega<dual_axis(j) & dual_axis(j)<-omega
%    left_partition(j)=rho((-dual_axis(j)-omega)/(-(L1-1)/step-2*omega));
%  elseif -omega<=dual_axis(j) & dual_axis(j)<=(L2-1)/step+omega
%    left_partition(j)=1;
%  elseif (L2-1)/step+omega<dual_axis(j) & dual_axis(j)<(R1+1)/step-omega
%    left_partition(j)=rho((dual_axis(j)-((L2-1)/step+omega))/((R1-L2+2)/step-2*omega));
%  else
%    left_partition(j)=0;
%  end
%end
%for j=1:length(dual_axis)
%  if dual_axis(j)<=(L2-1)/step+omega
%    right_partition(j)=0;
%  elseif (L2-1)/step+omega<dual_axis(j) & dual_axis(j)<(R1+1)/step-omega
%    right_partition(j)=1-rho((dual_axis(j)-((L2-1)/step+omega))/((R1-L2+2)/step-2*omega));
%  elseif (R1+1)/step-omega<=dual_axis(j) & dual_axis(j)<=omega
%    right_partition(j)=1;
%  elseif omega<dual_axis(j) & dual_axis(j)<(R2+1)/step-omega
%    right_partition(j)=rho((dual_axis(j)-omega)/((R2+1)/step-2*omega));
%  else
%    right_partition(j)=0;
%  end
%end


filters=zeros(n,length(dual_axis));
for j=1:n
  for k=1:kappa
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

%hold off
semilogy(y,abs(recon_signal-signal_origin),'k');
%pause
%hold on
%plot(h,10^(-2),'o');

%h/step
cond(A)

done=clock;
time_cost=done-begin;
time_cost=time_cost(6)+60*time_cost(5)+360*time_cost(4)

%L
%step

%for j=1:n
%  hold off
%  plot(dual_axis,real(filters(j,:)))
%  hold on
%  plot(dual_axis,imag(filters(j,:)),'r')
%  hold off
%  pause
%end
