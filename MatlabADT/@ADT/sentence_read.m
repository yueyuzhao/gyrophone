function [Odata smpr]=sentence_read(db,index)    
       %returns the wave data of a sentence
       file_name = [full_name(db,index) ,'.WAV'];
       [Odata smpr]= readsph(file_name);                     
end