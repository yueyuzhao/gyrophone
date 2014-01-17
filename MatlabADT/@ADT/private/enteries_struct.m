%23.2.08 - add filed: from
%27.3.08 - chenced from entery to entries
function [enteries] = enteries_struct
    word = struct('b',[],'e',[],'name',[],'flag',[]);
    phoneme = struct('b',[],'e',[],'name',[],'flag',[],'from',[]);
    enteries = struct('ID',[],'sentence',[],'usage',[],'dialect',[],'sex',[],'speaker',[],'phoneme',phoneme,'word',word);    
end