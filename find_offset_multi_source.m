function offset = find_offset_multi_source(samples1, samples2)
    [c, lags] = xcorr(samples1, samples2);
    [~, ind] = max(c);
    offset = lags(ind) + 1; % add 1 for Matlab indexing
end