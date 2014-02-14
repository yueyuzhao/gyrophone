% FILTER - returns a filterd set in which the field eqeals the value 
% and the numbers of enterys returns can be limited by max_returns.
% [Odb] = filter(db,field,value,max_returns); ver (23.2.8) 1.0
%Exemples:
%  set1  = filter(db,'word','she');  returns a TimitDB filterd word
%  set2 = filter(db,'dialect','~dr2');  returns a TimitDB filterd by
%  dialect diffrent form 'dr1'
%
%  See also query.
function [Odb returns] = filter(db,field,value,max_returns)
      
   if (value(1)=='~')       
         value = value(2:end);
         flip = 1;
   else
        flip = 0;
   end
         
   if value(end)=='*'
        value = value(1:end-1);
   else
        value = [value ' '];
   end
   
   if strcmp(value,'#all ')
       value = 'h#';
       flip = 1;
   end
      
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
        if (flip == 0)                
%               res = strncmpi([db.enteries(ii).(field),' '],value,length(value));
            res = regexpi([db.enteries(ii).(field),' '],value) == 1;
        else        
%            res = ~strncmpi([db.enteries(ii).(field),' '],value,length(value));
            res = ~(regexpi([db.enteries(ii).(field),' '],value) == 1);
        end          
        if res 
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