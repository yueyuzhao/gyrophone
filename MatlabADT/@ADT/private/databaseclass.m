%27.3.08 - add filed: name
function [db] = databaseclass
   enteries = enteries_struct();    
   db= struct('name',[],'path',[],'kind',[],'entriesNumber',[],'enteries',enteries);     
    db = class(db, 'ADT');
end