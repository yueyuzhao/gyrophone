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
       
   Odb = databaseclass(); %can be done by bulding a copy constarctor
   Odb.path = db.path;
   Odb.name = db.name;   
   Odb.kind = db.kind; %Can be changed to be selectet by the serech 
      
   returns = 0;
   is_pho=0;
   if strcmp(field,'phoneme'), is_pho=1; end
    
   if(strcmp(field,'word')||strcmp(field,'phoneme'))        
        
         for ii=1:length(db.enteries)  
                 in_sent=0;
                 for jj=1:length(db.enteries(ii).(field).flag)  %to chack if strcmp can recive a matrix
                 if db.enteries(ii).(field).flag(jj) == 1
                       if (flip == 0)                
                           res = strncmpi(db.enteries(ii).(field).name(jj,1:end),value,length(value));
                       else        
                           res = ~strncmpi(db.enteries(ii).(field).name(jj,1:end),value,length(value));
                       end  
                            
                       if ~res 
                            db.enteries(ii).(field).flag(jj) = 0;
                       else                            
                            if is_pho == 1
                                if db.enteries(ii).word.flag(db.enteries(ii).phoneme.from(jj))==1
                                    returns = returns + 1;
                                    in_sent = 1;
                                end
                            else
                                returns = returns + 1;
                                in_sent = 1;
                            end
                            if returns>=max_returns;
                                    db.enteries(ii).(field).flag(jj:end) = 0;
                                    db.enteries(ii).(field).flag(jj) = 1;
                                    Odb.enteries(end+1) = db.enteries(ii);
                                    Odb.enteries = Odb.enteries(2:end);                                    
                                    return;
                            end
                       end
                 end
                 end
                 if in_sent == 1
                          Odb.enteries(end+1) = db.enteries(ii);                                                                  
                 end
         end
         
         Odb.enteries = Odb.enteries(2:end); %to remove when bug fixed
         return;  
   end
     
   for ii=1:length(db.enteries)
        if (flip == 0)                
              res = strncmpi([db.enteries(ii).(field),' '],value,length(value));
        else        
              res = ~strncmpi([db.enteries(ii).(field),' '],value,length(value));
        end          
        if res 
               Odb.enteries(end+1) = db.enteries(ii);
               returns = returns + 1;
               if returns>=max_returns;
                           Odb.enteries = Odb.enteries(2:end);
                           return;
               end
        end          
    end

    Odb.enteries = Odb.enteries(2:end);
end