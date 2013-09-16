function [time, freq] = time_analysis(samples, fs, window, overlap)
    DEFAULT_WINDOW = 128;
    DEFAULT_OVERLAP = 0.5;
    
    if ~exist('window', 'var')
        window = DEFAULT_WINDOW;
    end;
    
    if ~exist('overlap', 'var')
        overlap = DEFAULT_OVERLAP;
    end;
    
    step = round(window * (1-overlap));
    
    pos = 1;
    time = [];
    freq = [];
    
    while pos < length(samples) - window
        sample_window = samples(pos:pos + window, :);
        time(end+1) = pos;
        freq(end+1) = find_max_freq(sample_window, fs);
        pos = pos + step;
    end;
    
    if nargout < 2
        plot(time, freq)
    end;
end

function max_freq = find_max_freq(samples, fs)
    START_FREQ = 50;
    hpsd = analyze_samples(samples, fs);
    ind = find(hpsd.Frequencies >= START_FREQ);
    start_ind = ind(1);
    
    [~, ind] = max((hpsd.Data(start_ind:end)));
    max_freq = hpsd.Frequencies(start_ind + ind - 1);
end