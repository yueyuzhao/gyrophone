function [timestamps, gyro, gyro_merged] = test_gyro_records
% Test with multiple Gyro samples of a signal
fs = 8000;

global GYRO_FS;
GYRO_FS = 200;
n = floor(fs / GYRO_FS);

ref_signal_name = 'ref_signal';
sample_name = 'triang-50-100_100-200hz';
DEVICES = {'00a697fa469633a5', '0094e779d7d1841f', '015d3fb673180c13', '04dc22d4dad7e4ce'};
NUM_DEVICES = 2; % length(DEVICES);

dim = 2;

timestamps = cell(NUM_DEVICES, 1);
gyro = cell(NUM_DEVICES, 1);
offset = zeros(NUM_DEVICES, 1);

[~, ~, ref_signal_ds] = read_ref_signal(ref_signal_name);

%% Find the offset at which the reference signal appears in
% each recording
all_rec_plot = figure;
hold all; 
for i = 1:NUM_DEVICES
    filename = ['gyro_results/Nexus/' DEVICES{i} '/' sample_name];
    [timestamps{i}, gyro{i}] = read_samples_file(filename);
    display([num2str(length(gyro{i})) ' samples in Gyro ' num2str(i) ' recording']);
    gyro{i} = normalization( gyro{i}(:, dim) );
    figure;
    fft_plot(gyro{i}, GYRO_FS);
    title(['Gyro ' num2str(i) ' samples']);
    figure(all_rec_plot);
    plot(gyro{i});
    offset(i) = find_offset(gyro{i}, ref_signal_ds);
end

legend(DEVICES{1:NUM_DEVICES});
display(offset);

original_signal_name = 'triang-50-100_100-200hz';
[~, ~, orig_sig_ds] = read_ref_signal(original_signal_name);

% find the shift in offset for which we get the 
% maximum correlation with the original signal
MAX_SHIFT = 10;
shift_range = -MAX_SHIFT:MAX_SHIFT;
score = zeros(length(shift_range));
for d1 = shift_range
    for d2 = shift_range
        shift_offset = [d1; d2];
        [~, gyro_merged, ~] = ...
            merge_sensor_data(timestamps, gyro, offset + shift_offset, GYRO_FS);
        gyro_merged = normalization(gyro_merged);
        max_corr = max(xcorr(gyro_merged, orig_sig_ds));
        score(d1 + MAX_SHIFT + 1, d2 + MAX_SHIFT + 1) = max_corr; 
    end;
end;

% pick best score and merge according to the corresponding offset shift
[~, max_score_ind] = max(score(:));
display(max_score_ind);
offset_shift = ind2sub(size(score), max_score_ind) - [MAX_SHIFT+1,MAX_SHIFT+1];
[~, gyro_merged, merged_fs] = ...
            merge_sensor_data(timestamps, gyro, offset + offset_shift, GYRO_FS);
gyro_merged = normalization(gyro_merged);


figure;
fft_plot(gyro_merged, merged_fs);
title('Merged from Gyro recordings');

gyro_resampled = resample(gyro_merged, fs, merged_fs);
% figure;
% subplot(121);
% fft_plot(gyro_resampled, fs);
% title('FFT After resampling');

soundsc(gyro_resampled, fs);

% filtered = bp_100_200hz(gyro_resampled);
% figure;
% fft_plot(filtered, fs);
% title('Filtered low frequencies');

% soundsc(filtered, fs);

end

function [merged_timestamps, merged_samples, merged_fs] = ...
    merge_sensor_data(timestamps, samples, offsets, fs)
    
    num_devices = length(samples);

    % trim recordings according to offsets
    % figure; hold all;
    for i = 1:num_devices
        trimmed_timestamps{i} = timestamps{i}(offsets(i):end);
        trimmed_samples{i} = samples{i}(offsets(i):end);
        % plot(trimmed_samples{i});
    end
    title('Trimmed signals');
    
    merged_timestamps = interleave_vectors(trimmed_timestamps);
    merged_samples = interleave_vectors(trimmed_samples);
    merged_fs = fs * num_devices;
    % [~, gyro_merged] = interpolate_samples(merged_timestamps, gyro_merged);
end

function [ref_signal, refsig_fs, ref_signal_ds] = ...
    read_ref_signal(sample_name)
global GYRO_FS;
[ref_signal, refsig_fs] = audioread(['samples/' sample_name '.wav']);
ref_signal_ds = resample(ref_signal, GYRO_FS * 2, refsig_fs);
ref_signal_ds = normalization(ref_signal_ds);
display(['Samples in ' sample_name ' (resampled): ' ...
    num2str(length(ref_signal_ds))]);
figure;
subplot(121);
fft_plot(ref_signal_ds, GYRO_FS * 2);
title('Reference signal FFT');
end