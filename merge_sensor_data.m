function [merged_timestamps, merged_samples, merged_fs] = ...
    merge_sensor_data(timestamps, samples, offsets, fs)
    
    num_devices = length(samples);

    shift = max(offsets) - offsets;
    
    % trim recordings according to offsets
    % figure; hold all;
    for i = 1:num_devices
        if ~isempty(timestamps)
            trimmed_timestamps{i} = timestamps{i}(shift(i)+1:end);
        end
        
        trimmed_samples{i} = samples{i}(shift(i)+1:end);
        % plot(trimmed_samples{i});
    end
    % title('Trimmed signals');
    
    if ~isempty(timestamps)
        merged_timestamps = interleave_vectors(trimmed_timestamps);
    else
        merged_timestamps = [];
    end
    merged_samples = interleave_vectors(trimmed_samples);
    merged_fs = fs * num_devices;
    % [~, gyro_merged] = interpolate_samples(merged_timestamps, gyro_merged);
end