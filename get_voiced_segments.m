function [wavdata, fs] = get_voiced_segments(input_filename)
    [output, fs] = silence_removal.detectVoiced(input_filename);
    fprintf('Detected %d voiced segments\n', length(output));
    
    % merge segments
    wavdata = [];
    for i = 1:numel(output)
        wavdata = [wavdata; output{i}];
    end
end