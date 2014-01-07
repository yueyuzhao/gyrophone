function offset = get_approximate_offset(timestamps, gyro_fs)
    MS_IN_SEC = 1e3;
    N = length(timestamps);
    
    start_times = zeros(size(timestamps));
    for i = 1:N
       start_times(i) = timestamps{i}(1); 
    end
    start_times_ms = ns_to_ms(start_times - min(start_times));
    
    offset = round(start_times_ms * gyro_fs / MS_IN_SEC);
end

function ms = ns_to_ms(ns)
    NANO_IN_MS = 1e6;
    ms = ns / NANO_IN_MS;
end