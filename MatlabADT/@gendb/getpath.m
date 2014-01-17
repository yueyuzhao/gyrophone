function path = getpath(db,index)
%GETPATH returns the full path of file
   path = full_path(db,db.enteries(index)); 
end