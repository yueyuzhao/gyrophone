function match(audio_file, gyro_rec, gyro_fs)
    % gyro_fs - Gyro sampling frequency
    
    % plot_spectrums(gyro_rec, GYRO_FS);
    
    [audio_samples, audio_fs] = audioread(audio_file);
    [gyro_timestamps, gyro_samples] = read_samples_file(gyro_rec);
    
    match_samples(audio_samples, audio_fs, gyro_samples, gyro_fs);
end