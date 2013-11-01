function time_skew = offset_to_timeskew(offset, N, fs)
    time_skew = mod(offset, N) / fs;
end