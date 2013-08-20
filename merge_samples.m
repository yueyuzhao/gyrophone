function [merged_timestamps, merged_signal] = merge_samples(timestamps1, samples1, timestamps2, samples2)
    merged_timestamps = sort([timestamps1; timestamps2]);
    merged_signal = zeros(length(timestamps1) + length(timestamps2), size(samples1, 2));
    
    pos1 = 1;
    pos2 = 1;
    for pos = 1:length(merged_timestamps)
        if pos1 <= length(timestamps1) && pos2 <= length(timestamps2)
            if timestamps1(pos1) < timestamps2(pos2)
                merged_signal(pos, :) = samples1(pos1, :);
                pos1 = pos1 + 1;
            else
                merged_signal(pos, :) = samples2(pos2, :);
                pos2 = pos2 + 1;
            end;
        else
            if pos1 <= length(timestamps1)
                merged_signal(pos, :) = samples1(pos1, :);
                pos1 = pos1 + 1;
            end;
            
            if pos2 <= length(timestamps2)
                merged_signal(pos, :) = samples2(pos2, :);
                pos2 = pos2 + 1;
            end;
        end;
    end;
end