function [db returns] = filterdb(db,varargin)
% FILTERDB - Return ADTobj subset of the ADTobj passed as an argument
% ADTobj = filterdb(ADTobj,criterion1,value1,...);
% See query function for the description of criteria arguments.
% Exemples:
% set1  = filterdb(db,'word',{'she','he'},'dialect','~dr2');
%
% See also query, filterdb, read, play.

%sets the maximum returns, n - the number of pairs
if mod(nargin,2)==1
    n = (nargin-1) /2;
    max_returns = 1000000;
else
    n = (nargin-2) /2;
    max_returns = varargin{nargin-1};
end

%sets the order of the serch for an improvment in speed
order = 1:n;
for ii=1:n-1
    index = ii;
    mini = fields_value(varargin{order(ii)*2-1});
    for jj=ii+1:n
        if(mini>fields_value(varargin{order(jj)*2-1}))
            mini = fields_value(varargin{order(jj)*2-1});
            index = jj;
        end
    end
    [order(ii) order(index)] = swap(order(ii),order(index));
end

%makes the serch by calls to filter / filter_or
for ii=1:n
    fprintf('Filtering: %s\n',varargin{order(ii)*2-1});
    if ii == n
        if iscell(varargin{order(ii)*2})
            [db returns] = filter_or(db,varargin{order(ii)*2-1},varargin{order(ii)*2},max_returns);
        else
            [db returns] = filter(db,varargin{order(ii)*2-1},varargin{order(ii)*2},max_returns);
        end
    else
        if iscell(varargin{order(ii)*2})
            db = filter_or(db,varargin{order(ii)*2-1},varargin{order(ii)*2});
        else
            db = filter(db,varargin{order(ii)*2-1},varargin{order(ii)*2});
        end
    end
end

%sets the finesd divition level
switch varargin{order(n)*2-1}
    case 'phoneme' , kind = 3;
    case 'word'    , kind = 2;
    otherwise      , kind = 1;
end
db.kind = kind;
db.entriesNumber = returns;
end

function [Oa Ob ] = swap(a,b)
Ob = a;
Oa = b;
end

function [pra] = fields_value(s)
switch s
    case 'usage',    pra = 4;
    case 'dialect',  pra = 3;
    case 'sex',      pra = 5;
    case 'speaker',  pra = 1;
    case 'sentence', pra = 2;
    case 'word',     pra = 6;
    case 'phoneme',  pra = 7;
    otherwise , error('Not a valid field, see help.');
end
end