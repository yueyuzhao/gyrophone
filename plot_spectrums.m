function plot_spectrums(filename, fs, flt)
    nfft = 64;
    [~, samples] = read_samples_file(filename);
    if exist('flt', 'var')
        samples = flt(samples);
    end;
    for k = 1:3
        figure;
        % specgram(samples(:, k), 128, 120);
        spectrogram(samples(:, k), hanning(nfft), round(nfft * 0.9), nfft, fs);
    end;
end