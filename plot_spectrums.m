function plot_spectrums(to_plot, fs, flt)
    % Plot 3 spectrogams (one for each gyro axis)
    % of the data. If to_plot is a filename it will
    % read the data from the file. to_plot can also
    % be a N-by-3 matrix of samples.
    % If flt is specified, it will be first called on
    % the samples.
    
    NFFT = 128;
    
    to_plot_type = whos('to_plot');
    if strcmp('char', to_plot_type.class)
       [~, samples] = read_samples_file(to_plot);
    else
       samples = to_plot;
    end
    
    if exist('flt', 'var')
        samples = flt(samples);
    end;
    
    for k = 1:3
        figure;
        % specgram(samples(:, k), 128, 120);
        spectrogram(samples(:, k), hanning(NFFT), round(NFFT * 0.9), NFFT, fs);
    end;
end