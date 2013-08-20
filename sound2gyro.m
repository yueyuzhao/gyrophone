% sound2gyro.m
% evaluate effect of sound signal on phone internal gyro
%  publish('sound2gyro.m','doc');

Fs = 200;                   % 200 sps default
[filenam, pathnam] = uigetfile('*.txt', 'get measurements data file');
fid = fopen(filenam,'r');
% 0.0
% 0.000000 -0.044288
% 5046272.000000 -0.044288
% L2:L212 =[txyz] (tinnsec)
% repeat n times
n=20;
f_in = zeros(n,1);
txyz = zeros(200,4,n);
frewind(fid),
i=1;
f_in(i) = str2double(fgetl(fid)); % read a line, 1st is noise freq
while ~isnan(f_in(i))
    linenums = 4;
    cntlines = 1;
    while linenums == 4
        % # of nums per line
        % counting for sampnum
        % loop to read one noise sequence
        tt = fgetl(fid);
        ttnum = str2num(tt);
        linenums = length(ttnum);      %
        if linenums ==4,
            txyz(cntlines,:,i) = ttnum;
            cntlines = cntlines+1;
        end;
    end;
    % get next line chars
    % make numbers
    sampnum = cntlines - 1;             % last was 1 or nan
    i = i+1;
    if isempty(ttnum), f_in(i)=nan; else f_in(i) = ttnum; end;
end

f_in(i:end)=[];             % clean the rest
txyz(:,:,i:end) = [];
n = i-1;                    % last one was NAN
% set  # of columns for plots
if n>5 
    pcols = 2; 
else
    pcols = 1;
end;
prows = n/pcols;
fclose(fid);

filenam = 'RAFDOCS-#7775044Magn.TXT';

if findstr(filenam,'77750')     % .. 28 | 44
    savetxyz = txyz;
    resamp;     % returns newtxyz, f_in, Fs, nlen
    len = min(nlen);
    txyz = zeros(len,4, length(f_in));
    for kf = 1:n,
        txyz(:,:,kf) = newtxyz{kf}(1:len,:);
    end
    xyz = txyz(:,2:4,:);
    time = squeeze(txyz(:,1,:));
    t = time;
else   %% verify, update ->  len, n
    len = 199;
    % clean
    % orig in nsec, Fs
    % clean
    t = repmat((0:len-1)'/Fs,1,n);
end;

xyzstr = 'XYZ';

xyz = txyz(1:len,2:4,:);      % 199x3xn
% x10 = squeeze(txyz(1:len,2,:));
% y10 = squeeze(txyz(1:len,3,:));
% z10 = squeeze(txyz(1:len,4,:));

for d = 1:3            % dimensions
    figure
    mn = min(min(squeeze(xyz(:,d,:))));
    mx = max(max(squeeze(xyz(:,d,:))));
    for i=1:n
        subplot(prows, pcols,i)
        curr = xyz(:,d,i);
        plot(t(:,i),curr,'.-')
        axis([0 t(end,i) mn mx]);
        title([ xyzstr(d) '-meas. for freq = ' num2str(f_in(i)) ' Hz'])
        xlabel('time [s]'), grid on
    end;
    if pcols>1,
        set(gcf,'posi',[80 80 750 1000])
    end;
    emarkpl( filenam)
end;

figure;
plot(diff(t(:,:)))
xlabel ('sample #')
ylabel('diff(time) [sec]')
title('Sample time interval variation')
dtser = diff(t);
[Val, Bin]=hist(dtser(:),100);      % Val, Bin
line(Val*len/max(Val),Bin,'linew',3,'colo','k')
axis tight
tmu = mean(dtser(:));
tsi = std (dtser(:));
legend(['\mu= ' num2str(tmu*1e3) ', \sigma= ' num2str(tsi*1e3) ' [ms]'])
emarkpl( filenam);

means = zeros(3,n);
sigms = means;
s1=24;              % 1st sample
if findstr(filenam,'7775028')
    s1 = 10;
end;
xyzCln = cell(3,1); % each cell is X, Y or Z, no transient
linecol='bgrcmyk';          % colors order
for d = 1:3        % dim
    xyzCln{d} = squeeze(xyz(s1:len,d,:));      %176xn samples, dimension d, all n freqs
    mn = min(xyzCln{d}(:)); mx = max(xyzCln{d}(:));
    aa = [0 1 mn mx];   % for all subplot axes
    figure
    for i=1:n
        subplot(prows, pcols,i)
        plot(t(s1:len,i),xyzCln{d}(:,i),'.-')
        axis(aa); grid on
        title([ xyzstr(d) '-meas. for freq = ' num2str(f_in(i)) ' Hz'])
        %sqd = squeeze(txyz(s1:len,d+1,i));
        means(d,i) = mean(xyzCln{d}(:,i));
        sigms(d,i) = std (xyzCln{d}(:,i));
        xlabel(['[\mu \sigma]=[' num2str([means(d,i) sigms(d,i)]) ']'])
    end
    if pcols>1
        set(gcf,'posi',[80 80 750 1000])
    end;
    emarkpl( filenam)
end;

subplot(211)
%semilogx(f_in, means','.-')
plot(f_in, means','.-')
title('mean')
legend('X', 'Y', 'Z',0)
axis tight, grid on
subplot(212)
%semilogx(f_in, sigms','.-')
plot(f_in, sigms','.-')
title('sigma')
legend('X', 'Y', 'Z',0)
xlabel ('disturb. freq')
axis tight, grid on
emarkpl( filenam)

figure
for d=1:3
    subplot(3,1,d)
    stem3(f_in,t(s1:end,1), xyzCln{d},'.')
    view(-26,34)
    mesh(audiof,t(s1:end,1), squeeze(xyz(s1:end,d,:)))
    contour3(audiof,t(s1:end,1), squeeze(xyz(s1:end,d,:)))
    xlabel('freq[Hz]'), ylabel('time[sec]'), title(xyzstr(d))
    axis tight
end;

if pcols>1,
    set(gcf,'posi',[80 80 750 1000])
end
emarkpl( filenam);

Hs=spectrum.welch;
% EstimationMethod: 'Welch'
%    SegmentLength: 64
% OverlapPercent: 50
%     WindowName: 'Hamming'
% SamplingFlag: 'symmetric'
% psd(Hs,,'Fs',Fs)

axnum = zeros(3,1);
for ax = 1:3,        % dim x, y or z
    axnum(ax) = figure    ;
    for i=1:n
        subplot(prows, pcols,i)
        psd(Hs,xyzCln{d}(:,i),'Fs',Fs);
        %  set(get(gca,'chi'),'colo','m'),
        axis tight,
        aa=axis;
        ine (rem(f_in(i),Fs/2)*[1;1],aa(3:4),'color', 'r')
        he=legend('PSD',['Noise freq=' num2str(f_in(i)) ' Hz'],0); 
        set(he,'fontsi',8, 'box', 'off');
    end;
    xlabel(['Frequency (Hz) Axis: ' xyzstr(ax)]);
end;
for ax = 1:3,
    figure(axnum(ax))
    if pcols>1,
        set(gcf,'posi',[80 80 750 1000])
    end
    emarkpl( filenam)
end;

Hs.SegmentLength = len-s1+1; % 176

axnum = zeros(3,1);
for ax = 1:3        % dim x, y or z
    % t_frqin = squeeze(txyz(s1:len,ax+1,:)); dimentions x freq.in
    axnum(ax) = figure    ;
    for i=1:n
        subplot(prows, pcols,i)
        psd(Hs,xyzCln{d}(:,i),'Fs',Fs);
        axis tight, aa=axis;
        line (rem(f_in(i),Fs/2)*[1;1],aa(3:4),'color', 'r')
        he=legend('PSD',['Noise freq=' num2str(f_in(i)) ' Hz']); 
        set(he,'fontsi',8, 'box', 'off');
    end;
    xlabel(['Frequency (Hz) Axis: ' xyzstr(ax)]);
end;
for ax = 1:3
    figure(axnum(ax))
    if pcols>1,
        set(gcf,'posi',[80 80 750 1000])
    end
    emarkpl( filenam)
end;