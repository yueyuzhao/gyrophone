function [wavdata, fs] = trim_silence(input_filename, output_filename)
	 [audio, fs] = audioread(input_filename);
   [wavdata, nseg] = get_voiced_segments(audio, fs);
   if nseg > 0
       audiowrite(output_filename, wavdata, fs);
   end
end
