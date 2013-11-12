function [offset, original, reconstructed] = test_downsampled
% Test non-uniform reconstruction with downsampled signals
% [original, fs] = audioread('samples/chirp-120-160hz.wav');
[original, fs] = audioread('samples/goodbye.wav');

NUM_DEVICES = 4;
global GYRO_FS;
GYRO_FS = 200;

USE_ORIGINAL_OFFSET = false;
REFINE_OFFSET = true;

original = resample(original, GYRO_FS * NUM_DEVICES, fs);

fs = GYRO_FS * NUM_DEVICES;

% Using generated test signal
% original = gen_test_signal(fs/2-100, fs, 500);

playsound(original, fs);
fft_plot(original, fs);
title('Original signal');

gyro = cell(NUM_DEVICES, 1);
estimated_offset = zeros(1, NUM_DEVICES);

% Generate random offsets
original_offset = gen_random_offset(50, NUM_DEVICES, fs);
% original_offset = 1:NUM_DEVICES;
display(original_offset);

N0 = 0; % noise PSD

% Downsampling with random offset - simulate time-interleaved ADCs
for i=1:NUM_DEVICES
    gyro{i} = downsample(original(original_offset(i):end), NUM_DEVICES);
    % We don't use normalization in the simulation, in case of a synthetic 
    % generated signal one of the DCs can sample only 0-s which
    % we don't want to normalize. Also, there is no need since
    % we sample the signal without simulating attenuation.
    gyro{i} = gyro{i} + N0*randn(size(gyro{i}));
end

for i=1:NUM_DEVICES
    estimated_offset(i) = find_offset(gyro{i}, GYRO_FS, original, fs);
end
display(estimated_offset);

%% Find time-skews
if USE_ORIGINAL_OFFSET
    offset = original_offset - min(original_offset);
else
    offset = estimated_offset - min(estimated_offset);
end
offset = offset - min(offset);

if REFINE_OFFSET
    % find the shift in offset for which we get the 
    % maximum correlation with the original signal
    MAX_SHIFT = 10;
    shift_range = -MAX_SHIFT:MAX_SHIFT;
    if NUM_DEVICES == 4
        possible_shift_offsets = combvec(shift_range, shift_range, shift_range)';
    elseif NUM_DEVICES == 2
        possible_shift_offsets = combvec(shift_range)';
    end;
    score = zeros(size(possible_shift_offsets, 1), 1);
    progressbar;
    for i = 1:length(score)
        shift_offset = [possible_shift_offsets(i, :) 0];
        new_offset = offset + shift_offset;
        time_skew = offset_to_timeskew(new_offset, NUM_DEVICES, fs);
        trimmed = trim_signals(gyro, new_offset);
        [reconstructed, ~] = eldar_reconstruction(GYRO_FS, trimmed, time_skew);
        reconstructed = normalization(reconstructed);
        max_corr = max(xcorr(reconstructed, original));
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

time_skew = offset_to_timeskew(offset, NUM_DEVICES, fs);
display(time_skew);
trimmed = trim_signals(gyro, offset);

[reconstructed, reconstructed_fs] = eldar_reconstruction(GYRO_FS, trimmed, time_skew);

figure;
fft_plot(reconstructed, reconstructed_fs);
title('Merged from recordings');
playsound(reconstructed, fs);

% figure;
% plot(xcorr(reconstructed, original));

% lp = fir1(48, [0.2 0.95]);
% filtered = filter(lp, 1, gyro_merged);
% figure;
% fft_plot(filtered, merged_fs);
% title('Filtered');
% playsound(filtered, merged_fs);

end

function test_signal = gen_test_signal(f, fs, timelen)
    t = 0:timelen;
    test_signal = sin(2*pi*f/fs*t);
end

function offset = gen_random_offset(MAX_OFFSET, NUM_DEVICES, fs)
    offset = randi([1, MAX_OFFSET], [1 NUM_DEVICES]);
    time_skew = offset_to_timeskew(offset, NUM_DEVICES, fs);
    while length(unique(time_skew)) ~= NUM_DEVICES
        offset = randi([1, MAX_OFFSET], [1 NUM_DEVICES]);
        time_skew = offset_to_timeskew(offset, NUM_DEVICES, fs);
    end
end