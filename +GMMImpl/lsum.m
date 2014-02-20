function lz=lsum(X,DIM);
% lz=lsum(X,DIM);
% 
% lz=log(x(1)+x(2)+....x(n))  X(i)= log(x(i)) ;
% 
% lsum(X)     sums along first dimension
% lsum(X,DIM) sums along dimension DIM

  
  if nargin==1
    DIM=1;
  end

  s=size(X);


  if DIM == 1
    % formula is:
    % lz=log(bigger)+log(1+sum(exp(log(others)-log(bigger))))
    
    % ************************************************************
    X=sort(X,1);   % just for find bigger in all dimensions
    lz=X(end,:,:,:,:)+...
       log(1+sum(exp(X(1:end-1,:,:,:,:)-...
                     repmat(X(end,:,:,:,:),[size(X,1)-1,1,1,1,1])),1));
    % ************************************************************
  else
    % we put DIM to first dimension and do the same as before
    X=permute(X,[ DIM, 1:DIM-1 , DIM+1:length(s)]);
    
    % ************************************************************
        X=sort(X,1);
    lz=X(end,:,:,:,:)+...
       log(1+sum(exp(X(1:end-1,:,:,:,:)-...
                     repmat(X(end,:,:,:,:),[size(X,1)-1,1,1,1,1])),1));
    % *************************************************************

    lz=permute(lz,[2:DIM, 1, DIM+1:length(s)]);
    % we bring back dimesions
  end
