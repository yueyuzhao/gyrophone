function [merged_signals] = merge_signals4(sig1, sig2, sig3, sig4, ...
    offset1, offset2, offset3, offset4, n)
    % Merge two signals sample-by-sample given the samples and offsets

    timestamps1 = offset1:n:offset1+length(sig1)*n - 1;
    timestamps2 = offset2:n:offset2+length(sig2)*n - 1;
    timestamps3 = offset3:n:offset3+length(sig3)*n - 1;
    timestamps4 = offset4:n:offset4+length(sig4)*n - 1;
    [~, merged_signals] = merge_samples4(timestamps1, sig1, ...
        timestamps2, sig2, timestamps3, sig3, timestamps4, sig4);
end