function [new_timestamps, new_samples] = interpolate_samples(timestamps, samples)
    % filter duplicate timestamps
    [timestamps, ind] = unique(timestamps);
    samples = samples(ind, :);
    
    dt = diff(timestamps);
    step = round(mean(dt));
    new_timestamps = round(timestamps(1)):step:round(timestamps(end));
    new_timestamps = double(new_timestamps(:));
    new_samples = interp1(double(timestamps), samples, new_timestamps, 'cubic');
end