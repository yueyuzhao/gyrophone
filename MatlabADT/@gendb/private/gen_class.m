%Database class (genDb)
function [db] = gen_class
   %enteries = enteries_struct();
   db= struct('name',[],'path',[],'format',[],'metaNames',[],'enteries',[]);          
   db = class(db, 'gendb');
end