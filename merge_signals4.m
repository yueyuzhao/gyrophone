function [merged_signals] = merge_signals4(sig1, sig2, sig3, sig4, ...
    offset1, offset2, offset3, offset4)
    % Merge two signals sample-by-sample given the samples and offsets

    timestamps1 = offset1:offset1+length(sig1) - 1;
    timestamps2 = offset2:offset2+length(sig2) - 1;
    timestamps3 = offset3:offset3+length(sig3) - 1;
    timestamps4 = offset4:offset4+length(sig4) - 1;
    [~, merged_signals] = merge_samples4(timestamps1, sig1, ...
        timestamps2, sig2, timestamps3, sig3, timestamps4, sig4);
end