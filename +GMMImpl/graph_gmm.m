function graph_gmm(X,mi,sig,c,coefs,ft)
% 
% graph_gmm(X,mi,sig,c,<coefs,ft>)
% 
% plots the distribution of coefficients
  
  
DEBUG=0;
PRINT=0;
[L,T]=size(X);

if (nargin<5), coefs=1:L; end
if (nargin<6), ft=0; end

LL=length(coefs);

li=fix(sqrt(LL));
co=ceil(LL/li);

figure(1);
clf;


for ll=1:LL 
l=coefs(ll);
  xm=min(X(l,:));
xM=max(X(l,:));
x=(-ft*(xM-xm)+xm):((ft+1)*(xM-xm)./100):(xM+ft*(xM-xm));

subplot(li,co,ll);

GMMImpl.histn(X(l,:),300);
hold on;

if DEBUG size(x),end

[laux,lmulti]=GMMImpl.lmultigauss(x,mi(l,:),sig(l,:),c);
aux=exp(laux);
multi=exp(lmulti);

if DEBUG size(x),size(multi'),pause,end

hp=plot(x,multi','r','Linewidth',1);
%xlim([ -xM xM ]);                    

ha=get(gca,'Children');
%it seem that the bars are children number 4

set(ha(2),'FaceColor',[ 0.8 0.8 0.8 ]);
set(ha(2),'EdgeColor',[ 0.8 0.8 0.8 ]);%*
end
