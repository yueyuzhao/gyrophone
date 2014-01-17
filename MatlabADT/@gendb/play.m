function play(db,index)
%PLAY plays the normelized waveform of the enterie
  [data smpr found] = sentence_read(db,index);
  max_v = max(data);
  data=data.*(1/max_v);
  if found==1 
      sound(data,smpr);
  end;   
end