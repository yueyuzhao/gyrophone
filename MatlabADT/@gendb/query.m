function [data smpr] = query(db,varargin) 
   db = filterdb(db,varargin{1:end});
   [data smpr] = read(db);
end