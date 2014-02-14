function [Hpsd, A] = analyze_samples(samples, Fs)
    % Return the Welch power-spectrum and the LPC coefficients of the
    % signal
    Hs = spectrum.welch;
    Hpsd = psd(Hs, samples, 'Fs', Fs);
    A = lpc(samples);
end