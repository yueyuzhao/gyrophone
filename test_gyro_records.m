function [timestamps, gyro, reconstructed] = ...
    test_gyro_records(sample_name, ref_signal_name)
% Test with multiple Gyro samples of a signal

GYRO_REC_DIR = '../data/gyro_results/Nexus';

global GYRO_FS;
GYRO_FS = 200;
% n = floor(fs / GYRO_FS);

% ref_signal_name = 'ref_signal';
% sample_name = 'triang-50-100_100-200hz';
DEVICES = {'00a697fa469633a5', '0094e779d7d1841f', '015d3fb673180c13', '04dc22d4dad7e4ce'};
NUM_DEVICES = 2; % length(DEVICES);
fs = NUM_DEVICES * GYRO_FS;

REFINE_OFFSET = true;
REFINE_TIMESKEW = true;
USE_APPROX_OFFSET = true;

reconstruction_func = @sp_eldar_impl;

dim = 1; % Gyro dimension to use

timestamps = cell(NUM_DEVICES, 1);

gyro = cell(NUM_DEVICES, 1);
offset = zeros(1, NUM_DEVICES);

% We resample the reference signal to 1xGYRO_FS since this is the 
% effective frequency a single devices can capture
[~, ~, ref_signal_ds] = read_signal(ref_signal_name, 1);
ref_signal_fs = GYRO_FS;

original_signal_name = sample_name;
[~, ~, orig_sig_ds] = read_signal(original_signal_name, NUM_DEVICES);

%% Read recorded samples
all_rec_plot = figure;
title('All recordings');
hold all;
for i = 1:NUM_DEVICES
    filename = [GYRO_REC_DIR '/' DEVICES{i} '/' sample_name];
    [timestamps{i}, gyro{i}] = read_samples_file(filename);
    display([num2str(length(gyro{i})) ' samples in Gyro ' num2str(i) ' recording']);
    gyro{i} = normalization( gyro{i}(:, dim) );
    figure;
    fft_plot(gyro{i}, GYRO_FS);
    title(['Gyro ' num2str(i) ' samples']);
    figure(all_rec_plot);
    plot(gyro{i});
end
legend(DEVICES{1:NUM_DEVICES});

%% Find approximate offset based on timestamps
approximate_offset = get_approximate_offset(timestamps, GYRO_FS)';
display(approximate_offset);

if USE_APPROX_OFFSET
    offset = approximate_offset;
else
    %% Find the offset at which the reference signal appears in
    % each recording
    for i = 1:NUM_DEVICES
        offset(i) = find_offset(gyro{i}, GYRO_FS, ref_signal_ds, ref_signal_fs);
    end
    % set minimal offset to 0 - prevent negative offsets
    offset = offset - min(offset);
    display(offset);
end

if REFINE_OFFSET
    offset = refine_offset(fs, offset, 10, NUM_DEVICES, gyro, orig_sig_ds, ...
        reconstruction_func);
end

time_skew = offset_to_timeskew(offset, NUM_DEVICES, ref_signal_fs);
trimmed = trim_signals(gyro, offset);

if REFINE_TIMESKEW
    time_skew = refine_timeskew(time_skew, NUM_DEVICES, trimmed, ...
        orig_sig_ds, reconstruction_func);
end

[reconstructed, reconstructed_fs] = reconstruction_func(GYRO_FS, trimmed, time_skew);

figure;
fft_plot(reconstructed, reconstructed_fs);
title('Merged from Gyro recordings');
playsound(reconstructed, reconstructed_fs);

% bp = fir1(48, [0.1 0.8]);
% filtered = filter(bp, 1, reconstructed);
% figure;
% fft_plot(filtered, fs);
% title('Filtered low frequencies');
% playsound(filtered, reconstructed_fs);

end