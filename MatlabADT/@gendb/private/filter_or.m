% FILTER - returns a filterd set in which the field eqeals the value 
% and the numbers of enterys returns can be limited by max_returns.
% [Odb] = filter(db,field,value,max_returns); ver (23.2.8) 1.0
%Exemples:
%  set1  = filter(db,'word','she');  returns a TimitDB filterd word
%  dialect diffrent form 'dr1'
%
%  See also query.

function [Odb returns] = filter_or(db,field,values,max_returns)
              
   %to add top (maximal amount of returns)
   if (nargin<4), max_returns = 5000000; end
      
   Odb = gen_class; %can be done by bulding a copy constarctor
   Odb.path = db.path;
   Odb.name = db.name;
   Odb.format = db.format;
   Odb.metaNames = db.metaNames;
   Odb.enteries = db.enteries(1);  
    
   returns = 0;
      
   for ii=1:length(db.enteries)
                           
        if my_cmp([db.enteries(ii).(field),' '],values)
               returns = returns + 1;
               Odb.enteries(returns) = db.enteries(ii);
               
               if returns>=max_returns;
                           Odb.enteries = Odb.enteries(2:end);
                           return;
               end
        end          
    end

    if returns==0, Odb.enteries = Odb.enteries(2:end); end
end

function res = my_cmp(reff,values)
    for val_index=1:length(values)
               if values{val_index}(end)=='*'
                   values{val_index} = values{val_index}(1:end-1);
               else
                   values{val_index} = [values{val_index} ' '];
               end
            res = strncmpi(reff,values{val_index},length(values{val_index}));
            if res==1, break; end
    end
end