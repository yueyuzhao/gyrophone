function offset = refine_offset(fs, offset, max_shift, num_devices, inputs, ...
    ref_signal, reconstruction_func)
    % Find the shift in offset for which we get the 
    % maximum correlation with the original signal
    global GYRO_FS;
    
    shift_range = -max_shift:max_shift;
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
        new_offset = offset + shift_offset;
        time_skew = offset_to_timeskew(new_offset, num_devices, fs);
        if range(time_skew) == 0
            % all elements are the same
            continue;
        end
        trimmed = trim_signals(inputs, new_offset);
        [reconstructed, ~] = reconstruction_func(GYRO_FS, trimmed, time_skew);
        reconstructed = normalization(reconstructed);
%         max_corr = max(xcorr(ref_signal, reconstructed));
%         score(i) = max_corr;
        ind = new_offset:new_offset + length(ref_signal)-1;
        ind = ind - min(ind) + 1;
        d(i) = get_dtw_distance(reconstructed(ind), ref_signal(:));
        progressbar(i / length(d));
    end;
    progressbar(1); % close progress bar
    % pick best score and merge according to the corresponding offset shift
%     [~, max_score_ind] = max(score);
    [~, min_d_ind] = min(d);
    offset_shift = [possible_shift_offsets(min_d_ind, :) 0];
    offset = offset + offset_shift;
    display(offset_shift); 
end