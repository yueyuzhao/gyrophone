function partition=new_partitions(zones,sigma,r,N,x)
%sigma=1;
%r=8.4;
T=r/2/sigma;
kappa=size(zones);
kappa=kappa(1);
%width=sigma*(2*N/r-1);
%x=-width:1/200:width;

partition=zeros(kappa,length(x));

if kappa==1
  k=kappa;
  for j=1:length(x)
      if x(j)<=(zones(k,1)-1)/T+sigma
        partition(k,j)=0;
      elseif (zones(k,1)-1)/T+sigma<x(j) & x(j)<-sigma
        partition(k,j)=rho((-x(j)-sigma)/(-2*sigma-(zones(k,1)-1)/T));
      elseif -sigma<=x(j) & x(j)<=sigma
        partition(k,j)=1;
      elseif sigma<x(j) & x(j)<(zones(k,2)+1)/T-sigma
        partition(k,j)=rho((x(j)-sigma)/((zones(k,2)+1)/T-2*sigma)); 
      else
        partition(k,j)=0; 
      end
  end
else
for k=1:kappa
  if k==1
    for j=1:length(x)
      if x(j)<=(zones(k,1)-1)/T+sigma
        partition(k,j)=0;
      elseif (zones(k,1)-1)/T+sigma<x(j) & x(j)<-sigma
        partition(k,j)=rho((-x(j)-sigma)/(-2*sigma-(zones(k,1)-1)/T));
      elseif -sigma<=x(j) & x(j)<=(zones(k+1,1)-1)/T+sigma
        partition(k,j)=1;
      elseif (zones(k+1,1)-1)/T+sigma<x(j) & x(j)<(zones(k,2)+1)/T-sigma
	partition(k,j)=rho((x(j)-((zones(k+1,1)-1)/T+sigma))/((zones(k,2)-zones(k+1,1)+2)/T-2*sigma));
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
  elseif k==kappa
    for j=1:length(x)
      if x(j)<=(zones(k,1)-1)/T+sigma
        partition(k,j)=0; 
      elseif (zones(k,1)-1)/T+sigma<x(j) & x(j)<(zones(k-1,2)+1)/T-sigma
        partition(k,j)=1-rho((x(j)-((zones(k,1)-1)/T+sigma))/((zones(k-1,2)-zones(k,1)+2)/T-2*sigma));
%      elseif sigma-1/T<x(j) & x(j)<(N/2-1)/T
%        partition(k,j)=rho((-x(j)+(N/2-1)/T)/(N/T/2-sigma))/2; 
%      elseif x(j)==(N/2-1)/T
%        partition(k,j)=1/2; 
%      elseif (N/2-1)/T<x(j) & x(j)<(N-1)/T-sigma
%        partition(k,j)=1-rho((x(j)-(N/2-1)/T)/(N/T/2-sigma))/2;  
      elseif (zones(k-1,2)+1)/T-sigma<=x(j) & x(j)<=sigma
        partition(k,j)=1; 
      elseif sigma<x(j) & x(j)<(zones(k,2)+1)/T-sigma
        partition(k,j)=rho((x(j)-sigma)/((zones(k,2)+1)/T-2*sigma)); 
      else
        partition(k,j)=0; 
      end
    end
  else
    for j=1:length(x)
      if x(j)<=(zones(k,1)-1)/T+sigma
        partition(k,j)=0;
      elseif (zones(k,1)-1)/T+sigma<x(j) & x(j)<(zones(k-1,2)+1)/T-sigma
        partition(k,j)=1-rho((x(j)-((zones(k,1)-1)/T+sigma))/((zones(k-1,2)-zones(k,1)+2)/T-2*sigma));
%      elseif (-N+k-1)/T+sigma<x(j) & x(j)<(k-1-N/2)/T
%        partition(k,j)=rho((-x(j)+(k-1-N/2)/T)/(N/T/2-sigma))/2;
%      elseif x(j)==(k-1-N/2)/T
%        partition(k,j)=1/2;
%      elseif (k-1-N/2)/T<x(j) & x(j)<(k-1)/T-sigma
%        partition(k,j)=1-rho((x(j)-(k-1-N/2)/T)/(N/T/2-sigma))/2;
      elseif (zones(k-1,2)+1)/T-sigma<=x(j) & x(j)<=(zones(k+1,1)-1)/T+sigma
        partition(k,j)=1;
      elseif (zones(k+1,1)-1)/T+sigma<x(j) & x(j)<(zones(k,2)+1)/T-sigma
        partition(k,j)=rho((x(j)-((zones(k+1,1)-1)/T+sigma))/((zones(k,2)-zones(k+1,1)+2)/T-2*sigma));
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
%  [k kappa]
%  zones(k,:)
%  pause
end
end
%plot(x,partition'); %'
%pause

%total=zeros(size(x));
%for j=1:N
%total=total+partition(j,:);
%end
%spy(1-total);




