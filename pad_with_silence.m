function pad_with_silence(input_dir, output_dir)
    EXT = '.wav';
    PAD_TIME = 0.5; % 0.5 second padding
    files = dir2(input_dir, EXT);
    for f = files
        input_file = f{1};
        output_file = strrep(input_file, input_dir, output_dir);
        
        [audio, fs] = audioread(input_file);
        padding = zeros(round(PAD_TIME * fs), 1);
        audio = [padding; audio; padding];
        
        try
            audiowrite(output_file, audio, fs);
        catch ME
            ME.stack(1)
            display(input_file);
            display(output_file);
        end
    end
end