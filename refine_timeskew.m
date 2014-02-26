function timeskew = refine_timeskew(timeskew, num_devices, trimmed, ref_signal, ...
    reconstruction_func)
    % Find the shift in offset for which we get the 
    % maximum correlation with the original signal
    global GYRO_FS;
    
    T = 1/GYRO_FS;
    MAX_SHIFT = 0.5 * T;
    STEP = 0.1 * T;
    
    shift_range = -MAX_SHIFT:STEP:MAX_SHIFT;
    if num_devices == 4
        possible_shift_offsets = combvec(shift_range, shift_range, shift_range)';
    elseif num_devices == 3
        possible_shift_offsets = combvec(shift_range, shift_range)';
    elseif num_devices == 2
        possible_shift_offsets = combvec(shift_range)';
    end;
%     score = zeros(size(possible_shift_offsets, 1), 1);
    d = zeros(size(possible_shift_offsets, 1), 1);
    progressbar;
    for i = 1:length(d)
        shift_offset = [possible_shift_offsets(i, :) 0];
        new_timeskew = timeskew + shift_offset;
        new_timeskew = new_timeskew - min(new_timeskew);
        if range(new_timeskew) == 0
            % all time skews are equal
            continue;
        end
        [reconstructed, ~] = reconstruction_func(GYRO_FS, trimmed, new_timeskew);
        reconstructed = normalization(reconstructed);
%         max_corr = max(xcorr(ref_signal, reconstructed));
%         score(i) = max_corr;
        ind = 1:length(ref_signal);
        d(i) = get_dtw_distance(reconstructed(ind), ref_signal(:));
        progressbar(i / length(d));
    end;
    progressbar(1); % close progress bar
    % pick best score and merge according to the corresponding offset shift
%     [~, max_score_ind] = max(score);
    [~, min_d_ind] = min(d);
%     timeskew_shift = [possible_shift_offsets(max_score_ind, :) 0];
    timeskew_shift = [possible_shift_offsets(min_d_ind, :) 0];
    timeskew = timeskew + timeskew_shift;
    timeskew = timeskew - min(timeskew);
    display(timeskew_shift); 
end