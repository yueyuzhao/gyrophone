function [this default_path] = ADT( dbName ,init_dir,flags)
%ADT - constructs a MatlabADT object.
%Technion SIPL MatlabADT (Audio Database Toolbox)
%Implemented by: Kobi Nistel 
%Supervised by: Yevgeni Litvin and Yair Moshe
%Version 1.01, Jan 2009
%Technical support: matlab_adt@sipl.technion.ac.il
%Lab site: www-sipl.technion.ac.il
%
%[ADTobj default_path] = ADT(dbName,init_dir,flags)
%All operations on the database will be performed using the
%ADT object which is passed to them as the first parameter.
%Exemples:
%  db  = ADT;  -  loads TIMIT  database form defalut path.
%  db2 = ADT('ctimit'); - loads CTIMIT database form the defalut path.
%Setup:
% on operating MatlabADT outside of SIPL for the first time run the command
% db = ADT('timit','c:\timitPath','setup');
%
%See also query, filterdb, read, play.

%checks the location of the timitdb directory
data_file_path = which('@ADT/ADT'); %to be fixed
data_file_path = data_file_path(1:end-5) ;%to be fixed

if (nargin<1)
    dbName = 'timit';
end
if (nargin<2)
    init_dir = textread([data_file_path dbName '_path.txt'],'%q');
    init_dir = init_dir{1};
end
if (nargin<3)
    flags='non';
end
if(strcmpi(flags,'setPath') || strcmpi(flags,'setup') || strcmpi(flags,'reBuild '))
    fid = fopen([data_file_path dbName '_path.txt'],'w+');
    fwrite(fid,['"' init_dir '"']);
    fclose(fid);
end

persistent cachedDBname;
persistent cachedDataBase; %for faster loading
this = databaseclass;
this.path = init_dir; %sets global path
this.kind = 1; %sets DB as sentence
this.name = dbName; %to do:from a file

%checks for exisitence of datafile
if( ~exist([data_file_path ,dbName,'.mat'], 'file') || strcmpi(flags,'reBuild '))
    this = makedb(init_dir,this);
    save([data_file_path,dbName],'this');
    cachedDataBase = this;
else
    fprintf('Loading %s...\n',this.name);
    if(isempty(cachedDataBase) || ~strcmp(cachedDBname,dbName))
        load([data_file_path,dbName]);
        this.path = init_dir; %sets db path
        cachedDataBase = this;
    else
        this =   cachedDataBase;
        this.path = init_dir; %sets db path
    end
end
default_path = this.path;
fprintf('Enteries: %d\n',this.entriesNumber);
cachedDBname = dbName;
if strcmpi(flags,'setup')
    play(this,1);
end
end


function this = makedb(init_dir,this)
%MAKEDB - generates the database file
fprintf('Generating database file:');
for train_testC=1:2   %USAGE: Test / Run
    switch train_testC
        case 1, train_test = 'train';
        case 2, train_test = 'test';
    end
    for dialectC=1:8 % Dialects
        fprintf('.');
        switch dialectC
            case 1,  dialect = 'dr1';
            case 2,  dialect = 'dr2';
            case 3,  dialect = 'dr3';
            case 4,  dialect = 'dr4';
            case 5,  dialect = 'dr5';
            case 6,  dialect = 'dr6';
            case 7,  dialect = 'dr7';
            case 8, dialect =  'dr8';
        end
        speaker_dirs = dir([init_dir,'\',train_test,'\',dialect,'\*.']); %speakers
        for sex_speakerC = 1:length(speaker_dirs)
            if( strcmpi(speaker_dirs(sex_speakerC).name(1) , 'F') )
                sex = 'F';
            else
                sex = 'M';
            end
            speaker = speaker_dirs(sex_speakerC).name(2:end); %Cutting the F/M
            direct=[init_dir,'\',train_test,'\',dialect,'\',speaker_dirs(sex_speakerC).name];
            files=dir([direct,'\*.wav']);
            for sentenceC = 1:length(files)
                
                %read on sentence data:
                this.enteries(end+1).ID = length(this.enteries); %couses an empty cell in db(1)!!
                this.enteries(end).sentence = files(sentenceC).name(1:end-4); %no exonetion
                this.enteries(end).usage = train_test;
                this.enteries(end).dialect = dialect;
                this.enteries(end).sex = sex;
                this.enteries(end).speaker = speaker;
                
                %read in sentence data:
                %words:
                [b,e,name]=textread([direct ,'\',this.enteries(end).sentence ,'.WRD'],'%n %n %s');
                %a "silence" word thet all not word assieted phonems
                %can point to.
                name{end+1}='h#';
                b(end+1) = 1;
                e(end+1) = 1;
                for temp=1:length(name), name{temp} = [name{temp},' ']; end
                %b = b+1; %the Timit readings starts from zero
                %e = e+1; %the Timit readings starts from zero
                this.enteries(end).word.name = char (name);
                this.enteries(end).word.b = b;
                this.enteries(end).word.e = e;
                this.enteries(end).word.flag =  ones(length(b),1,'int8');
                
                %phonems:
                [b,e,name]=textread([direct ,'\',this.enteries(end).sentence ,'.PHN'],'%n %n %s');
                for temp=1:length(name), name{temp} = [name{temp},' ']; end
                %b = b +1; %the Timit readings starts from zero
                %e = e +1; %the Timit readings starts from zero
                this.enteries(end).phoneme.name = char (name);
                this.enteries(end).phoneme.b = b;
                this.enteries(end).phoneme.e = e;
                this.enteries(end).phoneme.flag =  ones(length(b),1,'int8');
                this.enteries(end).phoneme.from =  length(this.enteries(end).word.flag)*ones(length(b),1,'int8');
                for pho_in=1:length(b)
                    for jj=1:length(this.enteries(end).word.b)
                        if(this.enteries(end).phoneme.b(pho_in)>=this.enteries(end).word.b(jj)-1)...
                                &&(this.enteries(end).phoneme.e(pho_in)<=this.enteries(end).word.e(jj)+1)
                            this.enteries(end).phoneme.from(pho_in)=jj;
                            continue;
                        end
                    end
                end
            end
        end
    end
end
fprintf('\n');
this.enteries = this.enteries(2:end);%becouse the first entery is empty
this.entriesNumber = length(this.enteries);
end