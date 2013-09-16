function [merged_timestamps, merged_signal] = ...
    merge_samples(timestamps1, samples1, timestamps2, samples2, ...
                  timestamps3, samples3, timestamps4, samples4)
    % Merge samples given their timestamps
    
    [merged_timestamps, ix] = sort([timestamps1(:); timestamps2(:); ...
        timestamps3(:); timestamps4(:)]);
    merged_signal = [samples1(:); samples2(:); samples3(:); samples4(:)];
    merged_signal = merged_signal(ix);
end