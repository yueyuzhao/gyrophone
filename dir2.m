function [varargout] = dir2(varargin)
%
% DIR2 finds files recursively (or not) in a given folder. Available args are:
%     list        a cell containing a list of files such as the result of dir2. Dir2
%                 searches among these files rather than in folders (args such as
%                 folder of recursive are ignored).
%
%     folder      the name of an existing folder ('.' and '..' are understood). If
%                 no folder is given, takes current one (pwd). Several folders may
%                 be given.
%
%     extension   the file extension to search ('.m' for example). Several extensions
%                 may be given too.
%
%     name        the file name to search ('test' for example)
%
%     wildcard    a partial name using * character with the following rule:
%                 'test*'   for filenames beginning with test;
%                 '*test*'  for filenames containing test;
%                 '*test'   for filenames ending with test.
%
%     date        the files modified after and/or before a given date. Examples:
%                 '>07-Jul-2006' for files modified after july 7th 2006;
%                 '<09-Aug-2006' for files modified before August 9th 2006.
%                 Takes only one date for both after and before. Note that only
%                 the formats 0,1,2,6,13,14,15,16,23 of DATESTR are recognized.
%
%     size        the lowest and/or greatest file size. Use 'kb' for Kbytes and 'mb'
%                 for Mbytes. Examples:
%                 '>200kb' for files larger than 200 Kbytes;
%                 '<10Mb' for files smaller than 10 Mbytes.
%
%     options     n     recursive depth (search up to the nth level of sub-folders).
%                 '/s'  silent mode
%                 '/n'  searches non-recursively.
%                 '/t'  search for files modified today (from 0:00 to now).
%                 '/y'  search for files modified yesterday (from yesterday 0:00 to now).
%                 '/w'  search for files modified this week (from monday 0:00 to now).
%                 '/i'  ignore case for filenames (note that extensions are always
%                       searched in lowercase).
%                                 
%
% Examples:
%
%     C=dir2 returns a cell C with the full pathname of all
%      files in current folder and its sub-folders.
%
%     C=dir2('c:\windows') returns a cell C with the full pathname of all
%      files in the c:\windows folder and all its sub-folders.
%
%     C=dir2('c:\windows','.exe') idem but returns only the files with
%      extension .exe.
%
%     C=dir2('c:\windows','.exe','.dll') idem but returns files with both
%      .exe and .dll extensions.
%
%     C=dir2('c:\windows','co*') idem but returns only the files starting with
%      the two letters co (comsetup.log, control.ini, ...).
%
%     C=dir2('c:\windows','co*','*dev*','*lis') idem but returns only the files
%      for which the name starts with co or contains dev or finishes by lis.
%
%     C=dir2('c:\windows','>07-Jul-2006') idem but returns files modified after
%      july 7th 2006.
%
%     C=dir2('c:\windows','>07-Jul-2006','<09-Jul-2006') idem but returns files
%      modified after july 7th 2006 and before july 9th 2006.
%
%     C=dir2('c:\windows','>253kb') idem but returns files with a size greater than
%      253 Kbytes. Use "mb" for Mbytes.
%
%     C=dir2('c:\windows','>253kb','<3mb') idem but returns files with a size greater
%      than 253 Kbytes and lower than 3 Mbytes.
%
%     C=dir2('c:\windows','.exe','<3mb') idem but returns files with .exe extension
%      and size lower than 3 Mbytes.
%
%     [C,F,D]=dir2('c:\windows') searches recursively in c:\windows, cell C contains
%      the files, cell F contains all the searched folders and vector D contains
%      the date numbers (so that you can sort the result by date).
%
%     C1=dir2('c:\windows') searches recursively in c:\windows and outputs a cell C1.
%     C2=dir2(C1,'.dll') searches in cell C1 files with a .dll extension.
%
%     dir2('c:\windows','.cmd') only displays the list of the .cmd files in
%      the Matlab command window
%
%           c:\windows\system32\login.cmd
%           c:\windows\system32\usrlogon.cmd
%
%     Note that extension should be given in lower case.
%
%     See also DIR (Matlab function) and DIRREC (Mathworks File Exchange).
%
%     Luc Masset (2007)

%initialisation
if nargout,
 varargout=[];
end

%process time
tic;

%input arguments
reper=[];
ext=[];
names=[];
ndate=[-Inf Inf];
nsize=[-Inf Inf];
isrec=1;
issilent=0;
ignorecase=0;
rdepth=Inf;
listF=cell(1,0);
listD=[];
for i=1:nargin,
 arg=varargin{i};
 if isempty(arg),
  continue;
 end
 if iscell(arg),
  n=length(listF);
  arg=arg(:)';
  nn=length(arg);
  listF(n+1:n+nn)=arg;
 elseif isnumeric(arg),
  rdepth=round(abs(arg(1)));
 elseif ~ischar(arg),
  error('argument should be a string')
 elseif strcmpi(arg,'/s'),
  issilent=1;
 elseif strcmpi(arg,'/i'),
  ignorecase=1;
 elseif strcmpi(arg,'/n'),
  isrec=0;
 elseif strcmpi(arg,'/t'),
  ndate(1)=floor(now);
 elseif strcmpi(arg,'/y'),
  ndate(1)=floor(now-1);
 elseif strcmpi(arg,'/w'),
  T=datevec(now);
  Year=T(1);
  Month=T(2);
  Day=T(3);
  va=datenum(floor(now));
  while 1,
   st=datestr(va,'ddd');
   if strcmp(st,'Mon'),
    break;
   end
   va=va-1;
  end
  ndate(1)=va;
 elseif exist(arg) == 7,
  if strcmp(arg,'.'),
   arg=pwd;
  end
  if strcmp(arg,'..'),
   arg=pwd;
  end
  [p,name,ext]=fileparts(arg);
  if isempty(p),
   names{end+1}=arg;
  else
   reper{end+1}=arg;
  end
 elseif strcmp(arg(1),'.'),
  ext{end+1}=arg;
 elseif arg(1) == '<' | arg(1) == '>',
  [ndate,nsize]=CheckArg(arg,ndate,nsize);
 else
  names{end+1}=arg;
 end
end
if ~rdepth,
 isrec=0;
end
if ~isempty(listF),
 reper=[];
else
 if isempty(reper),
  reper={pwd};
 end
end
if all(~isinf(ndate)),
 ndate=sort(ndate);
 if length(unique(ndate)) == 1,
  ndate(2)=Inf;
 end
end
if all(~isinf(nsize)),
 nsize=sort(nsize);
 if length(unique(nsize)) == 1,
  nsize(2)=Inf;
 end
end

%date
idate=1;
if isinf(ndate(1)) & isinf(ndate(2)),
 idate=0;
end

%size
isize=1;
if isinf(nsize(1)) & isinf(nsize(2)),
 isize=0;
end

%summary
zut={'non-recursively','recursively'};
if ~issilent,
 fprintf('\nDIR2........\n');
 if isempty(listF),
  fprintf('Search files %s in folder(s)',zut{isrec+1});
  for i=1:length(reper),
   fprintf(' %s',reper{i});
  end
  fprintf('\n');
 else
  fprintf('Search files in a list of %i files\n',length(listF));
 end
 if ~isempty(ext),
  fprintf('Files with extension(s)');
  for i=1:length(ext),
   fprintf(' %s',ext{i});
  end
  fprintf('\n');
 end
 if ~isempty(names),
  fprintf('With a name containing');
  for i=1:length(names),
   fprintf(' %s',names{i});
  end
  fprintf('\n');
  if ignorecase,
   fprintf('Ignore case: yes\n');
  else
   fprintf('Ignore case: no\n');
  end
 end
 if ~isinf(ndate(1)) & isinf(ndate(2))
  fprintf('Newer than %s\n',datestr(ndate(1)));
 elseif isinf(ndate(1)) & ~isinf(ndate(2))
  fprintf('Older than %s\n',datestr(ndate(2)));
 elseif ~isinf(ndate(1)) & ~isinf(ndate(2))
  fprintf('Newer than %s and older than %s\n',datestr(ndate(1)),datestr(ndate(2)));
 end
 if ~isinf(nsize(1)) & isinf(nsize(2))
  fprintf('With a size greater than %i Kbytes\n',round(nsize(1)/1024));
 elseif isinf(nsize(1)) & ~isinf(nsize(2))
  fprintf('With a size smaller than %i Kbytes\n',round(nsize(2)/1024));
 elseif ~isinf(nsize(1)) & ~isinf(nsize(2))
  fprintf('With a size greater than %i Kbytes and smaller than %i Kbytes\n',round(nsize(1)/1024),round(nsize(2)/1024));
 end
 if isrec & ~isinf(rdepth),
  fprintf('Recursion depth: %i folder(s)\n',rdepth);
 end
 fprintf('searching');
end

%searching the HDD or given list of files
if isempty(listF),
 iod=0;
 if nargout == 3, % we output the date (function datenum is time consuming)
  iod=1;
 end
 [listF,strN,listE,listR,listD]=SearchOnDisk(reper,isrec,rdepth,ext,idate,ndate,isize,nsize,iod,issilent);
else
 nF=length(listF);
 strN=[];
 listE=cell(1,nF);
 listR=cell(1,nF);
 indi=ones(1,nF);
 ncount=900;
 for i=1:length(listF),
  ncount=ncount+1;
  if ~issilent,
   if ~rem(ncount,100),
    fprintf('.');
    if ~rem(ncount,7000),
     fprintf('\n');
    end
   end
  end
  file=listF{i};
  [reper,fname,exte]=fileparts(file);
  if ~isempty(ext) & isempty(strmatch(exte,ext,'exact')),
   indi(i)=0;
   continue;
  end
  listE{i}=exte;
  strN=[strN '|' fname];
  listR{i}=reper;
 end
 if ~isempty(ext),
  indi=find(indi);
  listF=listF(indi);
  listE=listE(indi);
  listR=listR(indi);
 end
 listR=unique(listR);
 strN=[strN '|'];
end
nF=length(listF);
if ~issilent,
 fprintf('\n');
end

%filters on filenames
if ~isempty(names),
 if ignorecase,
  strN=lower(strN);
 end
 n0=strfind(strN,'|');
 indi=zeros(1,nF);
 for i=1:length(names),
  st=names{i};
  if isempty(strfind(st,'*')),
   st=['|' st '|'];
  elseif st(1) == '*',
   if st(end) == '*',
    st=strrep(st,'*','');
   else
    st=[st(2:end) '|'];
   end
  elseif st(end) == '*',
   st=['|' st(1:end-1)];
  end
  n=strfind(strN,st);
  if ~isempty(n),
   [zut,k]=histc(n,n0);
   indi(k)=1;
  end
 end
 indi=find(indi);
 listF=listF(indi);
 if ~isempty(listD),
  listD=listD(indi);
 end
end

%display results
if ~nargout,
 for i=1:length(listF),
  file=listF{i};
  [p,name,ext]=fileparts(file);
  switch ext,
  case '.m',
   fprintf('<a href="matlab:edit(''%s'')">edit</a> <a href="matlab: %s">run</a> %s\n',file,file,file);
  otherwise
   fprintf('<a href="matlab:try;winopen(''%s'');catch;disp(lasterr);end">%s</a>\n',file,file);
  end
 end
else
 varargout{1}=listF;
 varargout{2}=listR;
 varargout{3}=listD;
end

%process time
t=toc;
if ~issilent,
 if isempty(listF),
  fprintf('Nothing found ...\n');
 else
  fprintf('File(s) matching criteria: %i\n',length(listF));
 end 
 fprintf('Searched folder(s): %i\n',length(listR));
 fprintf('Elapsed time: %.1f sec.\n',t);
end

return

%------------------------------------------------------------------------------
function [listF,strN,listE,listR,listD] = SearchOnDisk(reper,isrec,rdepth,ext,idate,ndate,isize,nsize,iod,issilent)

%searching on the HDD
listF=[];               % cell containing the files
listE=[];               % cell containing the extensions
listD=[];               % vector containing the date numbers
strN=[];                % string containing only the name of files separated by |
listR=reper;            % cell containing all the searched folders
nF=0;                   % number of files found
nR=length(listR);       % number of folders found
indR=ones(1,nR);        % vector (same size as listR) indicating that a folder has
                        % been searched (0) or not (1)
depthR=zeros(1,nR);     % vector (same size as listR) indicating the depth of folders
                        % (0 for base folder, 1 for children, 2 for children of children etc)
ncount=9;               % we have already displayed "searching"
while 1,
 ind=find(indR);
 if isempty(ind),
  break;
 end
 ncount=ncount+1;
 if ~issilent,
  if rem(ncount,70),
   fprintf('.');
  else
   fprintf('.\n');
  end
 end
 ind=ind(1);
 idep=depthR(ind);
 rep=listR{ind};
 indR(ind)=0;
 S=dir(rep);
 n=length(S);
 listdir=cell(1,n);
 inddir=zeros(1,n);
 if iod,
  listD=[listD zeros(1,n)];
 end
 for i=1:n,
  name=S(i).name;
  if S(i).isdir,
   if strcmp(name,'.'),  % remove current folder (.)
    continue;
   end
   if strcmp(name,'..'), % remove parent folder (..)
    continue;
   end
   if isrec,
    listdir{i}=fullfile(rep,name);
    inddir(i)=1;
   end
  else
   [p,fname,exte]=fileparts(name);
   if ~isempty(ext) & isempty(strmatch(lower(exte),ext,'exact')),
    continue;
   end
   if iod | idate,
    vad=datenum(S(i).date);
   end
   if idate,
    if vad < ndate(1),
     continue;
    end
    if vad > ndate(2),
     continue;
    end
   end
   if isize,
    va=datenum(S(i).bytes);
    if va < nsize(1),
     continue;
    end
    if va > nsize(2),
     continue;
    end
   end
   nF=nF+1;
   listF{nF}=fullfile(rep,name);
   if iod,
    listD(nF)=vad;
   end
   listE{nF}=exte;
   strN=[strN '|' fname];
  end
 end
 if iod,
  listD=listD(1:nF);
 end
 if isrec,
  ind=find(inddir);
  if ~isempty(ind) & idep < rdepth,
   nn=length(ind);
   listR(nR+1:nR+nn)=listdir(ind);
   indR=[indR ones(1,nn)];
   depthR=[depthR idep+ones(1,nn)];
   nR=nR+nn;
  end
 end
end
strN=[strN '|'];

return


%------------------------------------------------------------------------------
function [ndate,nsize] = CheckArg(arg,ndate,nsize)

%initialisation
isdate=0;
issize=0;

%lower/greater
ipos=1;
if arg(1) == '<',
 ipos=2;
end
s=strrep(arg,'<','');
s=strrep(s,'>','');

%date
try,
 va=datenum(s);
 ndate(ipos)=va;
 return
catch
end

%file size
ss=lower(s);
if strfind(ss,'mb'),
 ss=strrep(ss,'mb','');
 va=1024^2*str2num(ss);
 if ~isempty(va),
  nsize(ipos)=va;
 end
elseif strfind(ss,'kb'),
 ss=strrep(ss,'kb','');
 va=1024*str2num(ss);
 if ~isempty(va),
  nsize(ipos)=va;
 end
else
 va=str2num(ss);
 if ~isempty(va),
  nsize(ipos)=va;
 else
  st=sprintf('unable to understand arg "%s"',arg);
  error(st)
 end
end

return

