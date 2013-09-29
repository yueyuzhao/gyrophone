function fft_plot(samples, Fs)
    N = length(samples);
    df = Fs/N;
    f = -Fs/2:df:Fs/2-df;
    Y = fftshift(abs(fft(samples)));
    subplot(121);
    plot(f, Y);
    subplot(122);
    nfft = 128;
    spectrogram(samples, hanning(nfft), round(nfft*0.9), nfft, Fs);
end