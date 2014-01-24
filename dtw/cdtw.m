function [Dist,D,k,w,rw,tw]=cdtw(r,t,pflag)
%
% [Dist,D,k,w,rw,tw]=cdtw(r,t,pflag)
%
% Continuous Dynamic Time Warping Algorithm using a Linear Interpolation Model
% r is the vector you are testing
% t is the vector you are testing against
% Dist is unnormalized distance between rw and tw
% D is the accumulated distance matrix
% k is the normalizing factor
% w is the optimal path
% rw is the warped r vector
% tw is the warped t vector
% pflag  plot flag: 1 (yes), 0(no)
%
% Copyright (c) 2007 by Pau Micó

[row,M]=size(r); if (row > M) M=row; r=r'; end;
[row,N]=size(t); if (row > N) N=row; t=t'; end;

% Distances matrix
d=zeros(2*M-1,2*N-1);
for i=1:2:2*M-1
    m=floor(i/2)+1;
    for j=1:2:2*N-1
        n=floor(j/2)+1;
        d(i,j)=(r(m)-t(n))^2;
        if (m<M & n<N)
            if ((t(n)<=r(m) & r(m)<=t(n+1)) | (t(n+1)<=r(m) & r(m)<=t(n))) d(i,j+1)=0;
            else d(i,j+1)=min([r(m)-t(n) r(m)-t(n+1)].^2);
            end
            if ((r(m)<=t(n) & t(n)<=r(m+1)) | (r(m+1)<=t(n) & t(n)<=r(m))) d(i+1,j)=0;
            else d(i+1,j)=min([t(n)-r(m) t(n)-r(m+1)].^2);
            end
        end
    end
end

% Accumulated distance matrix
D=zeros(size(d));
D(1,1)=d(1,1);
for i=3:2:2*M-1
    D(i-1,1)=d(i-1,1)+D(i-2,1);
    D(i,1)=d(i,1)+D(i-1,1);
end
for j=3:2:2*N-1
    D(1,j-1)=d(1,j-1)+D(1,j-2);
    D(1,j)=d(1,j)+D(1,j-1);
end
for i=3:2:2*M-1
    for j=3:2:2*N-1
        D(i-1,j)=d(i-1,j)+D(i-2,j);
        D(i,j-1)=d(i,j-1)+D(i,j-2);
        D(i,j)=d(i,j)+min([D(i,j-1) D(i-1,j) D(i-2,j-2)]);
    end
end

% Looking for the optimal path
i=2*M-1;
j=2*N-1;
w=[M N];
rw=r(end);
tw=t(end);
while ((i+j)~=2)
    m=floor(i/2)+1;
    n=floor(j/2)+1;
    if (i-2)<0 
        w=[m n-1; w];
        rw=[r(m) rw];
        tw=[t(n-1) tw];
        j=j-2;
    elseif (j-2)<0 
        w=[m-1 n; w];
        rw=[r(m-1) rw];
        tw=[t(n) tw];
        i=i-2;
    else
        [values,number]=min([D(i,j-1) D(i-1,j) D(i-2,j-2)]);
        switch (number)
            case 1,
                if ((t(n-1)<=r(m) & r(m)<=t(n)) | (t(n)<=r(m) & r(m)<=t(n-1))) x=(r(m)-t(n-1))/(t(n)-t(n-1));
                elseif ((r(m)-t(n-1))^2 <= (r(m)-t(n))^2) x=0;
                else x=1;
                end
                w=[m n-1+x; w];
                rw=[r(m) rw];
                tw=[x*(t(n)-t(n-1))+t(n-1) tw];
                j=j-2;
            case 2,
                if ((r(m-1)<=t(n) & t(n)<=r(m)) | (r(m)<=t(n) & t(n)<=r(m-1))) x=(t(n)-r(m-1))/(r(m)-r(m-1));
                elseif ((t(n)-r(m-1))^2 <= (t(n)-r(m))^2) x=0;
                else x=1;
                end
                w=[m-1+x n; w];
                rw=[x*(r(m)-r(m-1))+r(m-1) rw];
                tw=[t(n) tw];
                i=i-2;
            case 3,
                w=[m-1 n-1; w];
                rw=[r(m-1) rw];
                tw=[t(n-1) tw];
                i=i-2;
                j=j-2;
        end
    end
end

% D normalization in order to plot w
D=D(1:2:2*M-1,1:2:2*N-1);
Dist=sum((rw-tw).^2);
k=size(w,1);

if pflag
    
    % --- Accumulated distance matrix and optimal path
    figure('Name','CDTW - Accumulated distance matrix and optimal path', 'NumberTitle','off');
    
    main1=subplot('position',[0.19 0.19 0.67 0.79]);
    image(D);
    cmap=contrast(D);
    colormap(cmap); % 'copper' 'bone', 'gray' imagesc(D);
%     colormap('gray'); % 'copper' 'bone', 'gray' imagesc(D);
%     brighten(0.7);
    hold on;
    x=w(:,1); y=w(:,2);
    ind=find(x==1); x(ind)=1+0.2;
    ind=find(x==M); x(ind)=M-0.2;
    ind=find(y==1); y(ind)=1+0.2;
    ind=find(y==N); y(ind)=N-0.2;
    plot(y,x,'-w', 'LineWidth',1);
    hold off;
    axis([1 N 1 M]);
    set(main1, 'FontSize',7, 'XTickLabel','', 'YTickLabel','');

    colorb1=subplot('position',[0.88 0.19 0.05 0.79]);
    nticks=8;
    ticks=floor(1:(size(cmap,1)-1)/(nticks-1):size(cmap,1));
    mx=max(max(D));
    mn=min(min(D));
    ticklabels=floor(mn:(mx-mn)/(nticks-1):mx);
    colorbar(colorb1);
    set(colorb1, 'FontSize',7, 'YTick',ticks, 'YTickLabel',ticklabels);
    set(get(colorb1,'YLabel'), 'String','Distance', 'Rotation',-90, 'FontSize',7, 'VerticalAlignment','bottom');
    
    left1=subplot('position',[0.07 0.19 0.10 0.79]);
    plot(r,M:-1:1,'-b');
    set(left1, 'YTick',mod(M,10):10:M, 'YTickLabel',10*floor(M/10):-10:0)
    axis([min(r) 1.1*max(r) 1 M]);
    set(left1, 'FontSize',7);
    set(get(left1,'YLabel'), 'String','Samples', 'FontSize',7, 'Rotation',-90, 'VerticalAlignment','cap');
    set(get(left1,'XLabel'), 'String','Amp', 'FontSize',6, 'VerticalAlignment','cap');
    
    bottom1=subplot('position',[0.19 0.07 0.67 0.10]);
    plot(t,'-r');
    axis([1 N min(t) 1.1*max(t)]);
    set(bottom1, 'FontSize',7, 'YAxisLocation','right');
    set(get(bottom1,'XLabel'), 'String','Samples', 'FontSize',7, 'VerticalAlignment','middle');
    set(get(bottom1,'YLabel'), 'String','Amp', 'Rotation',-90, 'FontSize',6, 'VerticalAlignment','bottom');
    
    % --- Warped signals
    figure('Name','CDTW - warped signals', 'NumberTitle','off');
    
    subplot(1,2,1);
    set(gca, 'FontSize',7);
    hold on;
    plot(r,'-bx');
    plot(t,':r.');
    hold off;
    axis([1 max(M,N) min(min(r),min(t)) 1.1*max(max(r),max(t))]);
    grid;
    legend('signal 1','signal 2');
    title('Original signals');
    xlabel('Samples');
    ylabel('Amplitude');
    
    subplot(1,2,2);
    set(gca, 'FontSize',7);
    hold on;
    plot(rw,'-bx');
    plot(tw,':r.');
    hold off;
    axis([1 k min(min([rw; tw])) 1.1*max(max([rw; tw]))]);
    grid;
    legend('signal 1','signal 2');
    title('Warped signals');
    xlabel('Samples');
    ylabel('Amplitude');
    
end
