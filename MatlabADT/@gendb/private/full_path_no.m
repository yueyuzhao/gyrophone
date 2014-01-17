function [ path ] = full_path_no( db,enterie )
%FULL_PATH Summary of this function goes here
%   Detailed explanation goes here
   path=[db.path '/'];
   for ii=1:length(db.metaNames)
       if ~isempty(enterie.(db.metaNames{ii}))
           path = [path enterie.(db.metaNames{ii}),'/'];
       end
   end
   path = path(1:end-1);
end
