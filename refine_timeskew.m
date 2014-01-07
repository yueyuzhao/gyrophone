function timeskew = refine_timeskew(timeskew, num_devices, trimmed, ref_signal)
    % Find the shift in offset for which we get the 
    % maximum correlation with the original signal
    global GYRO_FS;
    
    MAX_SHIFT = 5e-4;
    STEP = 1e-4;
    
    shift_range = -MAX_SHIFT:STEP:MAX_SHIFT;
    if num_devices == 4
        possible_shift_offsets = combvec(shift_range, shift_range, shift_range)';
    elseif num_devices == 2
        possible_shift_offsets = combvec(shift_range)';
    end;
    score = zeros(size(possible_shift_offsets, 1), 1);
    progressbar;
    for i = 1:length(score)
        shift_offset = [possible_shift_offsets(i, :) 0];
        new_timeskew = timeskew + shift_offset;
        new_timeskew = new_timeskew - min(new_timeskew);
        [reconstructed, ~] = eldar_reconstruction(GYRO_FS, trimmed, new_timeskew);
        reconstructed = normalization(reconstructed);
        max_corr = max(xcorr(ref_signal, reconstructed));
        score(i) = max_corr;
        progressbar(i / length(score));
    end;
    progressbar(1); % close progress bar
    % pick best score and merge according to the corresponding offset shift
    [~, max_score_ind] = max(score);
    timeskew_shift = [possible_shift_offsets(max_score_ind, :) 0];
    timeskew = timeskew + timeskew_shift;
    timeskew = timeskew - min(timeskew);
    display(timeskew_shift); 
end