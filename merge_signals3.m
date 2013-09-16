function [merged_signals] = merge_signals3(sig1, sig2, sig3, offset1, offset2, offset3, n)
    % Merge two signals sample-by-sample given the samples and offsets

    timestamps1 = offset1:n:offset1+length(sig1)*n - 1;
    timestamps2 = offset2:n:offset2+length(sig2)*n - 1;
    timestamps3 = offset3:n:offset3+length(sig3)*n - 1;
    [~, merged_signals] = merge_samples3(timestamps1, sig1, ...
        timestamps2, sig2, timestamps3, sig3);
end