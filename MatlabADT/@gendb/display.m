
function display(db)
%DISPLAY Summary of this function goes here
%   Detailed explanation goes here
    fprintf('%s Database -\n',db.name);
    fprintf('Path: %s\n',db.path);
    fprintf('Format: %s\n',db.format);
    fprintf('Enteries number: %d\n',length(db.enteries));
    fprintf('------------ Enteries ------------\n');
    for ii=1:min(length(db.enteries),100) 
      fprintf('\nEnterie number: %d\n',ii);
      for metaNamesN=1:length(db.metaNames)         
          fprintf('%s: %s\n',db.metaNames{metaNamesN},db.enteries(ii).(db.metaNames{metaNamesN}));
      end
    end
    if length(db.enteries)>100, fprintf('\n...\n\n'); end
end