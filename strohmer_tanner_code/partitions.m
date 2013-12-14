function partition=new_partitions(sigma,r,x)
%sigma=1;
%r=8.4;
T=r/2/sigma;
N=ceil(r);
%width=sigma*(2*N/r-1);
%x=-width:1/200:width;

partition=zeros(N,length(x));

for k=1:N
  if k==1
    for j=1:length(x)
      if x(j)<=sigma-N/T
        partition(k,j)=0;
      elseif sigma-N/T<x(j) & x(j)<-sigma
        partition(k,j)=rho((-x(j)-sigma)/(N/T-2*sigma));
      elseif -sigma<=x(j) & x(j)<=(1-N)/T+sigma
        partition(k,j)=1;
      elseif (1-N)/T+sigma<x(j) & x(j)<1/T-sigma
	partition(k,j)=rho((x(j)-((1-N)/T+sigma))/(N/T-2*sigma));
%      elseif (1-N)/T+sigma<x(j) & x(j)<(1-N/2)/T
%        partition(k,j)=1-rho((-x(j)+(1-N/2)/T)/(N/T/2-sigma))/2;
%      elseif x(j)==(1-N/2)/T
%        partition(k,j)=1/2;
%      elseif (1-N/2)/T<x(j) & x(j)<1/T-sigma
%        partition(k,j)=rho((x(j)-(1-N/2)/T)/(N/T/2-sigma))/2;
      else
        partition(k,j)=0;
      end
    end
  elseif k==N
    for j=1:length(x)
      if x(j)<=sigma-1/T
        partition(k,j)=0; 
      elseif sigma-1/T<x(j) & x(j)<(N-1)/T-sigma
        partition(k,j)=1-rho((x(j)-(sigma-1/T))/(N/T-2*sigma));
%      elseif sigma-1/T<x(j) & x(j)<(N/2-1)/T
%        partition(k,j)=rho((-x(j)+(N/2-1)/T)/(N/T/2-sigma))/2; 
%      elseif x(j)==(N/2-1)/T
%        partition(k,j)=1/2; 
%      elseif (N/2-1)/T<x(j) & x(j)<(N-1)/T-sigma
%        partition(k,j)=1-rho((x(j)-(N/2-1)/T)/(N/T/2-sigma))/2;  
      elseif (N-1)/T-sigma<=x(j) & x(j)<=sigma
        partition(k,j)=1; 
      elseif sigma<x(j) & x(j)<N/T-sigma
        partition(k,j)=rho((x(j)-sigma)/(N/T-2*sigma)); 
      else
        partition(k,j)=0; 
      end
    end
  else
    for j=1:length(x)
      if x(j)<=(-N+k-1)/T+sigma
        partition(k,j)=0;
      elseif (-N+k-1)/T+sigma<x(j) & x(j)<(k-1)/T-sigma
        partition(k,j)=1-rho((x(j)-((-N+k-1)/T+sigma))/(N/T-2*sigma));
%      elseif (-N+k-1)/T+sigma<x(j) & x(j)<(k-1-N/2)/T
%        partition(k,j)=rho((-x(j)+(k-1-N/2)/T)/(N/T/2-sigma))/2;
%      elseif x(j)==(k-1-N/2)/T
%        partition(k,j)=1/2;
%      elseif (k-1-N/2)/T<x(j) & x(j)<(k-1)/T-sigma
%        partition(k,j)=1-rho((x(j)-(k-1-N/2)/T)/(N/T/2-sigma))/2;
      elseif (k-1)/T-sigma<=x(j) & x(j)<=(-N+k)/T+sigma
        partition(k,j)=1;
      elseif (-N+k)/T+sigma<x(j) & x(j)<k/T-sigma
        partition(k,j)=rho((x(j)-((-N+k)/T+sigma))/(N/T-2*sigma));
%      elseif (-N+k)/T+sigma<x(j) & x(j)<(k-N/2)/T
%        partition(k,j)=1-rho((-x(j)+(k-N/2)/T)/(N/T/2-sigma))/2;
%      elseif x(j)==(k-N/2)/T
%        partition(k,j)=1/2;
%      elseif (k-N/2)/T<x(j) & x(j)<k/T-sigma
%        partition(k,j)=rho((x(j)-(k-N/2)/T)/(N/T/2-sigma))/2;
      else
        partition(k,j)=0;
      end
    end
  end
%  plot(x,partition(k,:))
%  axis([min(x) max(x) 0 1])
%  [k N]
%  pause
end
%plot(x,partition'); %'
%pause

%total=zeros(size(x));
%for j=1:N
%total=total+partition(j,:);
%end
%spy(1-total);




