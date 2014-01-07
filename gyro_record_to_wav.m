function gyro_record_to_wav(input_file, output_dir, fs)
    % Convert Gyro recording to WAV file
    % fs - Sampling frequency
    [~, samples] = read_samples_file(input_file);
    for i = 1:3
       % for each axis
       [~, name, ~] = fileparts(input_file);
       output_file = [output_dir '/' num2str(i) '/' name  '.wav'];
       y = samples(:, i);
%        SR = 200;
%        resampled = resample(y, SR, fs);
%        audiowrite(output_file, resampled, SR);
       audiowrite(output_file, y, fs);
       trim_silence(output_file, output_file);
    end
end