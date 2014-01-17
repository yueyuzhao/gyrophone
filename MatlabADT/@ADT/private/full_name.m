%returns full path and name (without exeontion) of a file by index

function [full_name] = full_name(db,index)
    full_name = [db.path,'/',db.enteries(index).usage,'/',db.enteries(index).dialect...
    ,'/',db.enteries(index).sex,db.enteries(index).speaker,'/',db.enteries(index).sentence];
end
