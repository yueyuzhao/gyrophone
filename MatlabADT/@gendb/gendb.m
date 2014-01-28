function [ db ] = gendb( name )
%Technion SIPL MatlabADT (Audio Database Toolbox)
%Version 1.01, Jan 2009
%Implemented by: Kobi Nistel 
%Supervised by: Yevgeni Litvin and Yair Moshe
%Technical support: matlab_adt@sipl.technion.ac.il
%Lab site: www-sipl.technion.ac.il
%
%GENDB - constructs a gendb object.
%[db] = gendb(dbName)
%All operations on the database will be performed using the
%ADT object which is passed to them as the first parameter.
%Exemples:
%  db  = gendb('yoho');  -  loads YOHO  database.
  db = gen_class;
  db.name =name;
  gendbClassPath = which('@gendb/gendb'); 
  gendbClassPath = gendbClassPath(1:end-7);
 
  instancePath = [gendbClassPath ,'instance/',name];
 
  defaultPath = textread([instancePath ,'/default_path.txt'],'%q');
  db.path = defaultPath{1};
  format = textread([instancePath ,'/format.txt'],'%s');
  db.format = format{1};
  metaNames = textread([instancePath ,'/meta_names.txt'],'%s');
  db.metaNames = metaNames;
  
  for ii=1:length(metaNames)
      enterie.(metaNames{ii}) = '';
  end
  
  if( ~exist([instancePath '/datafile.mat'], 'file'))           
      db = bulidDatabase(db,enterie,1);
      save([instancePath '/datafile'],'db');
  else
      fprintf('Loading %s...\n',db.name);      
      load([instancePath '/datafile']);      
  end
  fprintf('Enterie number:%d\n',length(db.enteries));
end

function db = bulidDatabase(db,enterie,depth)
    path = full_path_no(db,enterie);
    fprintf('%s\n',path);
    dirs_names = dir(path);    
    file_names = dir([path '/*.', db.format]);  
    for filesN=1:length(file_names)
       db.enteries(end+1).(db.metaNames{length(db.metaNames)}) = file_names(filesN).name(1:end-4);%****
       for dirsN=1:depth-1           
             db.enteries(end).(db.metaNames{dirsN}) = enterie.(db.metaNames{dirsN});          
       end
    end   
    %files_path(end+1).name='';
    for dirsN=1:length(dirs_names) 
      if( (~strcmp(dirs_names(dirsN).name,'.'))&& (~strcmp(dirs_names(dirsN).name,'..')) && (dirs_names(dirsN).isdir))
        enterie.(db.metaNames{depth}) = dirs_names(dirsN).name;
        db = bulidDatabase(db,enterie,depth+1);
      end
    end
end
