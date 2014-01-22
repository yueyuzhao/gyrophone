function convert_gyro_records_to_wav(input_dir, output_dir)
% Convert gyro recordings to WAV files
files = dir(input_dir);
GYRO_FS = 200;

for i = 1:length(files)
    if files(i).isdir || files(i).name(1) == '.'
        % skip directories and hidden files
        continue;
    end
    
    filename = [input_dir '/' files(i).name];
    gyro_record_to_wav(filename, output_dir, GYRO_FS);
end