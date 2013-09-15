function match_samples(audio_samples, audio_fs, gyro_samples, gyro_fs)
    display(length(gyro_samples));
    
    display(audio_fs);
    display(length(audio_samples));
    
    audio_resampled = resample(audio_samples, gyro_fs, audio_fs);
    display(length(audio_resampled));
    
    plot( conv(gyro_samples(:,1), fliplr(audio_resampled)) );
end