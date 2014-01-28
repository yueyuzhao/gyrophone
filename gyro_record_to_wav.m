function gyro_record_to_wav(input_file, output_dir, fs)
    % Convert Gyro recording to WAV file
    % fs - Sampling frequency
    [~, samples] = read_samples_file(input_file);
    for i = 1:3
       % for each axis
       [~, name, ~] = fileparts(input_file);
       output_file = [output_dir '/' num2str(i) '/' name  '.wav'];
       y = samples(:, i);
       SR = 8000;
       wavdata = resample(y, SR, fs);
       
       % cut 0.5 second at the beginning and a second from the end
       wavdata = wavdata(4000:end-8000);
       
       % trim silence
       [wavdata, nseg] = get_voiced_segments(wavdata, SR);
       
       % Write file
       audiowrite(output_file, wavdata, SR);
    end
end
