function [ path ] = full_path( db,enterie )
%FULL_PATH Summary of this function goes here
%   Detailed explanation goes here
   path=[db.path '/'];
   for ii=1:length(db.metaNames)
       path = [path enterie.(db.metaNames{ii}),'/'];
   end
   path =[path(1:end-1),'.',db.format];
end
