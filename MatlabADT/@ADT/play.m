function play(db,index)
%PLAY - plays a MatlabADT sentence.
%play(ADTobj,index)
%See also query, filterdb, read, play.
[data,smpr] = read(db,index);
for i=1:length(data)
    sound(data{i},smpr);
end
end
