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
        spectrogram(samples(:, k), NFFT, round(NFFT*0.9), NFFT);
        % Using AuditoryToolbox spectrogram
%         spec = spectrogram(samples(:, k), NFFT, 2, 2);
%         x = (0 : size(spec, 2) - 1) / fs;
%         y = 0 : size(spec, 1) - 1;
%         imagesc(x, y, spec);
%         xlabel('Time [sec]');
%         ylabel('Freq [Hz]');
    end;
end