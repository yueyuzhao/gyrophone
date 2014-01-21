function [mu,sigm,c]=gmm_estimate(X,M,iT,mu,sigm,c,Vm)
% [mu,sigma,c]=gmm_estimate(X,M,<iT,mu,sigm,c,Vm>)
% 
% X   : the column by column data matrix (LxT)
% M   : number of gaussians
% iT  : number of iterations, by defaut 10
% mu  : initial means (LxM)
% sigm: initial diagonals for the diagonal covariance matrices (LxM)
% c   : initial weights (Mx1)
% Vm  : minimal variance factor, by defaut 4 ->minsig=var/(M²Vm²)

  DEBUG=0;
  GRAPH=0;
  
  % *************************************************************
  % GENERAL PARAMETERS
  [L,T]=size(X);        % data length
  varL=var(X')';    % variance for each row data;
  
  min_diff_LLH=0.001;   % convergence criteria

  % DEFAULTS
  if nargin<3  iT=10; end   % number of iterations, by defaut 10
  if nargin<4  mu=X(:,[fix((T-1).*rand(1,M))+1]); end % mu def: M rand vect.
  if nargin<5  sigm=repmat(varL./(M.^2),[1,M]); end % sigm def: same variance
  if nargin<6  c=ones(M,1)./M; end  % c def: same weight
  if nargin<7  Vm=4; end   % minimum variance factor
  
  min_sigm=repmat(varL./(Vm.^2*M.^2),[1,M]);   % MINIMUM sigma!
 
  if DEBUG sqrt(devs),sqrt(sigm),pause;end

  % VARIABLES
  lgam_m=zeros(T,M);    % prob of each (X:,t) to belong to the kth mixture
  lB=zeros(T,1);        % log-likelihood
  lBM=zeros(T,M);       % log-likelihhod for separate mixtures


  old_LLH=-9e99;        % initial log-likelihood

  % START ITERATATIONS  
  for iter=1:iT
    if GRAPH graph_gmm(X,mu,sigm,c),pause,end
    if DEBUG disp(['************ ',num2str(iter),' *********************']);end
    
    % ESTIMATION STEP ****************************************************
    [lBM,lB] = lmultigauss(X,mu,sigm,c);
    
    if DEBUG lB,B=exp(lB),pause; end
 
    LLH=mean(lB);

    if DEBUG 
        disp(sprintf('log-likelihood :  %f',LLH));
    end
    
    lgam_m=lBM-repmat(lB,[1,M]);  % logarithmic version
    gam_m=exp(lgam_m);            % linear version           -Equation(1)
    
    
    % MAXIMIZATION STEP **************************************************
    sgam_m=sum(gam_m);            % sum of gam_m for all X(:,t)
    
     
    % gaussian weights ************************************
    new_c=mean(gam_m)';      %                                -Equation(4)

    % means    ********************************************
    % (convert gam_m and X to (L,M,T) and .* and then sum over T)
    mu_numerator=sum(permute(repmat(gam_m,[1,1,L]),[3,2,1]).*...
               permute(repmat(X,[1,1,M]),[1,3,2]),3);
    % convert  sgam_m(1,M,N) -> (L,M,N) and then ./
    new_mu=mu_numerator./repmat(sgam_m,[L,1]);              % -Equation(2)

    % variances *******************************************
    sig_numerator=sum(permute(repmat(gam_m,[1,1,L]),[3,2,1]).*...
                permute(repmat(X.*X,[1,1,M]),[1,3,2]),3);
    
    new_sigm=sig_numerator./repmat(sgam_m,[L,1])-new_mu.^2; % -Equation(3)

    % the variance is limited to a minimum
    new_sigm=max(new_sigm,min_sigm);
    

    %*******
    % UPDATE

    if old_LLH>=LLH-min_diff_LLH
%       disp('converge');
      break;
    else
      old_LLH=LLH;
      mu=new_mu;
      sigm=new_sigm;
      c=new_c;
    end
    
    %******************************************************************
  end
