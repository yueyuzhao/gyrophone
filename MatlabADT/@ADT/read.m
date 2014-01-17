function [data smpr meta] = read(db,index)
%READ - returns waveform from ADT object.
%[data smpr meta] = read(ADTobj,index).
% See query function for the description of the
% output arguments.
%Exemples:
%  wave  = read(ADTobj);  -  returns wave data in the form of cell array.
%  wave = read(ADTobj,5); - returns wave data only from sentence 5;
%
%See also query, filterdb, read, play.

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
    
    for  index=from:to  %reads data according to the database kind
        
        if db.kind==1 %reads sentences
            count = count + 1;
            [Odata(count).data smpr] = sentence_read(db,index);
            Odata(count).info =getmeta(db,index);
        end
        
        if db.kind==2 %reads words
            [data smpr] = sentence_read(db,index);
            for ii=1:length(db.enteries(index).word.b)
                if db.enteries(index).word.flag(ii)==1
                    count = count + 1;
                    b = db.enteries(index).word.b(ii);
                    e = db.enteries(index).word.e(ii);
                    Odata(count).data = data(b:e);
                    Odata(count).info = getmeta(db,index);
                    Odata(count).info.word = strrep(db.enteries(index).word.name(ii,1:end),' ','');                    
                    Odata(count).info.wordNumber = ii;
                end
            end
        end
        
        if db.kind==3 %reads phomemes
            [data smpr] = sentence_read(db,index);
            for ii=1:length(db.enteries(index).phoneme.b)
                b = db.enteries(index).phoneme.b(ii);
                e = db.enteries(index).phoneme.e(ii);
                in_word = db.enteries(index).word.flag(db.enteries(index).phoneme.from(ii));
                if(db.enteries(index).phoneme.flag(ii)==1)&&(in_word==1)
                    count = count + 1;
                    Odata(count).data = data(b:e);
                    Odata(count).info = getmeta(db,index);
                    Odata(count).info.word = strrep(db.enteries(index).word.name(db.enteries(index).phoneme.from(ii),1:end),' ','');
                    Odata(count).info.phoneme = strrep(db.enteries(index).phoneme.name(ii,1:end),' ','');
                end
            end
        end
    end
    %converts resalt in the from of struct to cellarray
    data = cell(length(Odata),1);
    meta = cell(length(Odata),1);
    for ii=1:length(Odata)
        data{ii} = Odata(ii).data;
        meta{ii} = Odata(ii).info;
    end
    fprintf('Enteries: %d\n', length(Odata));
else
    fprintf('An empty Database!\n');
    data = [];
    meta =[];
    smpr = [];
end
end