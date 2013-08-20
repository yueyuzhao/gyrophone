function Hpsd = analyze_samples(samples, Fs)
    Hs = spectrum.welch;
    Hpsd = psd(Hs, samples, 'Fs', Fs);
end