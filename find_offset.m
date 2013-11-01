function offset = find_offset(sig, sig_fs, ref_signal, ref_signal_fs)
    % Find the lag between two signals using cross-correlation  
    sig_us = resample(sig, ref_signal_fs, sig_fs);
    sig_us = normalization(sig_us);
    [c, lags] = xcorr(normalization(ref_signal), sig_us);
    [~, ind] = max(c);
    offset = lags(ind) + 1; % add 1 for Matlab indexing
end