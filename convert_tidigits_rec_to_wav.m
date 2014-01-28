function convert_tidigits_rec_to_wav(input_dir, output_dir)
    EXT = '.gyr';
    GYRO_FS = 200;
    files = dir2(input_dir, EXT);
    for f = files
        input_file = f{1};
        output_file = strrep(input_file, input_dir, output_dir);
        current_output_dir = fileparts(output_file);
        for i = 1:3
            mkdir([current_output_dir filesep num2str(i)]);
        end
        
        try
            gyro_record_to_wav(input_file, current_output_dir, GYRO_FS);
        catch ME
            ME.stack(1)
            display(input_file);
            display(current_output_dir);
        end
    end
end