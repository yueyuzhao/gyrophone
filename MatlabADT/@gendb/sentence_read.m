
function [data smpr found] = sentence_read(db,index)    
    found = 0;
    path = full_path(db,db.enteries(index));    
    if exist(path, 'file')             
        if strcmp('WAV',db.format)
            found=1;
%             [data smpr]= readsph(path);
            [data smpr]= audioread(path);
        end;
        if strcmp('wav',db.format)
            found=1;
            [data smpr]= wavread(path);
        end;
        if strcmp('mp3',db.format)
            found=1;
            [data smpr]= mp3read(path);
        end;
				if strcmp('gyr', db.format)
					found = 1;
					[timestamps, data] = read_samples_file(path);
					smpr = 200; % Gyro sampling rate
        end;
    else
        fprintf('file not found:error 1\n');        
    end
    if found==0
        data='';
        smpr='';
        fprintf('no support for this format:error 2\n');  
    end
end
