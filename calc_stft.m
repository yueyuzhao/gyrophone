function features = calc_stft(wavdata, samp_rate)
    WINDOW = 512;
    WINDOW_OVERLAP = WINDOW * 0.75;
    features = specgram(wavdata, WINDOW, samp_rate, WINDOW_OVERLAP);
end