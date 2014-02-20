function H=histn(x,ncont)
% H=HISTN(X,NumberOfContainers)
% 
% plots a normalized histogram
% i.e. follows the distribution probability function)
% H is a vector of path handles
  
 [y,bc]=hist(x,ncont);
nc=sum(y).*(bc(2)-bc(1));
H=bar(bc,y./nc,'hist');
