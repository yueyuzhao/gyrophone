function fft_plot(samples, Fs)
    N = length(samples);
    df = Fs/N;
    f = -Fs/2:df:Fs/2-df;
    Y = fftshift(abs(fft(samples)));
    plot(f, Y);
end