function [YM,Y]=multigauss(x,mi,sigm,c)
% [YM,Y]=multigauss(x,mu,sigm,c)
% 
% computes multigaussian likelihood
% 
% x   : data (columnwise vectors)
% sigm: variances vector  (diagonal of the covariance matrix)
% mu  : means
% c   :the weights
DEBUG=0;
  
[L,T]=size(x);

if DEBUG L,T,end

M=size(c,1);

if DEBUG M,end

% repeating, changing dimensions:
X=permute(repmat(x',[1,1,M]),[1,3,2]);      % (T,L) -> (T,M,L) one per mixture

Sigm=permute(repmat(sigm,[1,1,T]),[3,2,1]); % (L,M) -> (T,M,L)

Mu=permute(repmat(mi,[1,1,T]),[3,2,1]);     % (L,M) -> (T,M,L)

if DEBUG size(X),size(Mu),size(Sigm),pause;end


%Y=squeeze(exp( 0.5.*dot(X-Mu,(X-Mu)./Sigm))) % L dissapears: (L,T,M) -> (T,M)
lY=-0.5.*dot(X-Mu,(X-Mu)./Sigm,3);
% c,const -> (T,M) and then multiply by old Y
coef=(2.*pi).^(L./2).*sqrt(prod(sigm,1)); % c,const -> (T,M)
lcoef=repmat(log(c')-log(coef),[T,1]);

if DEBUG log(coef),lcoef,lY,pause;end

YM=exp(lcoef+lY);            % ( T,M ) one mixture per column
Y=sum(YM,2);                 % add mixtures 
