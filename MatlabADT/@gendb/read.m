function [data smpr] = read(db,index)
    if ~isempty(db.enteries)
        
        Odata=struct();
        count = 0;
        if nargin<2 %if index not enterd reads from all sentances
                  from = 1; 
                  to = length(db.enteries);
        else         %else read only form sentence number index
                   from = index;
                   to = index;
        end
        
        fprintf('Reading Data... \n');
        data=cell(to-from+1,1);
        for  index=from:to  %reads data according to the database kind                       
                count = count + 1;     
                [data{count} smpr] = sentence_read(db,index);                                         
        end                            
        %fprintf('Enteries: %d\n', length(Odata));   
    else
        fprintf('An empty Database!!!\n');
        data = [];        
        smpr = [];
    end                                                                                                                                            
end