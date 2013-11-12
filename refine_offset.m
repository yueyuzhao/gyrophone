function offset = refine_offset(fs, offset, max_shift, num_devices, inputs, ref_signal)
    % Find the shift in offset for which we get the 
    % maximum correlation with the original signal
    global GYRO_FS;
    
    shift_range = -max_shift:max_shift;
    if num_devices == 4
        possible_shift_offsets = combvec(shift_range, shift_range, shift_range)';
    elseif num_devices == 2
        possible_shift_offsets = combvec(shift_range)';
    end;
    score = zeros(size(possible_shift_offsets, 1), 1);
    progressbar;
    for i = 1:length(score)
        shift_offset = [possible_shift_offsets(i, :) 0];
        new_offset = offset + shift_offset;
        time_skew = offset_to_timeskew(new_offset, num_devices, fs);
        trimmed = trim_signals(inputs, new_offset);
        [reconstructed, ~] = eldar_reconstruction(GYRO_FS, trimmed, time_skew);
        reconstructed = normalization(reconstructed);
        max_corr = max(xcorr(ref_signal, reconstructed));
        score(i) = max_corr;
        progressbar(i / length(score));
    end;
    progressbar(1); % close progress bar
    % pick best score and merge according to the corresponding offset shift
    [~, max_score_ind] = max(score);
    offset_shift = [possible_shift_offsets(max_score_ind, :) 0];
    offset = offset + offset_shift;
    display(offset_shift); 
end