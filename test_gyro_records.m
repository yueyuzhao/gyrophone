%% Test with downsampled signals
clear;
AMP = 1000; % amplification

fs = 8000;

GYRO_FS = 200;
n = floor(fs / GYRO_FS);

sample_name = 'chirp-120-160hz';
timestamps = {};
gyro = {};

DEVICES = {'00a697fa469633a5', '0094e779d7d1841f', '015d3fb673180c13', '04dc22d4dad7e4ce'};

dim = 2;

timestamps = {};
gyro = {};
offset = [];

figure; hold all; 
for i = 1:4
    filename = ['gyro_results/Nexus/' DEVICES{i} '/' sample_name];
    [timestamps{i}, gyro{i}] = read_samples_file(filename);
    gyro{i} = gyro{i}(:, dim);
    plot(gyro{i});
    [val, offset(i)] = max(abs(gyro{i})); 
end

gyro_merged = merge_signals4(gyro{1}(offset(1):end), ...
    gyro{2}(offset(2):end), ...
    gyro{3}(offset(3):end), ...
    gyro{4}(offset(4):end), ...
    1, 2, 3, 4, ...
    n);
merged_fs = GYRO_FS * 4;

figure;
fft_plot(gyro_merged, merged_fs);
title('Merged from two recordings');

gyro_resampled = resample(gyro_merged, fs, merged_fs);
figure;
fft_plot(gyro_resampled, fs);
title('After resampling');

filtered = hp_filt(gyro_resampled);
figure;
fft_plot(filtered, fs);
title('Filtered low frequencies');

%soundsc(gyro_resampled * AMP, fs);
soundsc(filtered * AMP, fs);