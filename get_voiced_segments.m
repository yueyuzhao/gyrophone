function [wavdata, fs, nseg] = get_voiced_segments(wavdata, fs)
    v = 0; % verbosity, show graphs
    [output, nseg] = silence_removal.detectVoiced(wavdata, fs, v);
    fprintf('Detected %d voiced segments\n', length(output));
    
    % merge segments
    wavdata = [];
    for i = 1:nseg
        wavdata = [wavdata; output{i}];
    end
end