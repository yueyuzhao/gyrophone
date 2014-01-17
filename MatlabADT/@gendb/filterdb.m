%FILTERDB - returns a filterd set by pairs of field and value
% [Odb] = filterdb(db,[field,value...],max_returns); 
%Exemples:
% set1  = filterdb(db,'word','she','dialect','~dr2');  
% returns a set of word she and not dr2
%
%See also query.
function [db returns] = filterdb(db,varargin)
    
    %sets the maximum returns, n - the number of pairs
    if mod(nargin,2)==1 
        n = (nargin-1) /2;
        max_returns = 1000000;
    else
        n = (nargin-2) /2;
        max_returns = varargin{nargin-1};
    end
    
    %sets the order of the serch, order - contains the order of the serch
    order = 1:n;
%     for ii=1:n-1
%        index = ii;
%        mini = fields_value(varargin{order(ii)*2-1});
%        for jj=ii+1:n
%            if(mini>fields_value(varargin{order(jj)*2-1}))
%                mini = fields_value(varargin{order(jj)*2-1});
%                index = jj;
%            end
%        end
%        [order(ii) order(index)] = swap(order(ii),order(index));
%     end
 
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
            
end

% function [Oa Ob ] = swap(a,b)
%   Ob = a;
%   Oa = b;
% end
% 
% function [pra] = fields_value(s)
%     switch s
%         case 'usage',    pra = 4;
%         case 'dialect',  pra = 3;    
%         case 'sex',      pra = 5;           
%         case 'speaker',  pra = 1;          
%         case 'sentence', pra = 2;    
%         case 'word',     pra = 6;    
%         case 'phoneme',  pra = 7;
%         otherwise , error('Not a valid field, see help timitdb.');
%     end
% end