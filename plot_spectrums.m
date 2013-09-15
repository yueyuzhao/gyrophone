function plot_spectrums(filename, fs)
    nfft = 256;
    [~, samples] = read_samples_file(filename);
    for k = 1:3
        figure;
        % specgram(samples(:, k), 128, 120);
        spectrogram(samples(:, k), hanning(nfft), round(nfft * 0.9), nfft, fs);
    end;
end