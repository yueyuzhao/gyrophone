function display(db)
%  overload function thet displays  ADTobj

    fprintf('%s database -\n',db.name);
    fprintf('Path: %s\n',db.path);
    fprintf('Class of: ');
    switch db.kind
        case 1, fprintf('Sentences\n');
        case 2, fprintf('Words\n');    
        case 3, fprintf('Phonemes\n');
        otherwise , fprintf('Sentences\n');    
    end
    fprintf('Enteries number: %d\n',db.entriesNumber);    
    fprintf('Sentences number: %d\n\n',length(db.enteries));    
    for ii=1:min(length(db.enteries),100) 
        %fprintf('Index - ID: %d - %d\n',ii,db.enterys(ii).ID);
        fprintf('Words: ');
         for jj=1:length(db.enteries(ii).word.flag)-1        
                if db.enteries(ii).word.flag(jj)==1
                        fprintf('%s ',strrep(db.enteries(ii).word.name(jj,:),' ','') );
                end
         end 
        fprintf('\nUsage: %s\n',db.enteries(ii).usage);
        fprintf('Dialect: %s\n',db.enteries(ii).dialect);
        fprintf('Sex: %s\n',db.enteries(ii).sex);
        fprintf('Speaker: %s\n',db.enteries(ii).speaker);
        fprintf('Sentence: %s\n\n',db.enteries(ii).sentence);
    end
    if length(db.enteries)>100, fprintf('...\n\n'); end
end