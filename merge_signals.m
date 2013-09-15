function [merged_signals] = merge_signals(sig1, sig2, offset1, offset2, n)
    % Merge two signals sample-by-sample given the samples and offsets

    timestamps1 = offset1:n:offset1+length(sig1)*n - 1;
    timestamps2 = offset2:n:offset2+length(sig2)*n - 1;
    [~, merged_signals] = merge_samples(timestamps1, sig1, ...
        timestamps2, sig2);
end