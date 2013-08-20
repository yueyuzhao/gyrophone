function plot_spectrums(filename, fs)
    [~, samples] = read_samples_file(filename);
    for k = 1:3
        figure;
        spectrogram(samples(:, k), 128, 120, fs);
    end;
end