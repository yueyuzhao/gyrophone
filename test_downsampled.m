%% Test with downsampled signals
clear;
close all;
% [original, fs] = audioread('samples/chirp-120-160hz.wav');
[original, fs] = audioread('samples/goodbye.wav');
original = resample(original, 8000, fs);
fs = 8000;
soundsc(original, fs);
fft_plot(original, fs);
title('Original signal');

GYRO_FS = 200;
% GYRO_FS = fs / 2;
n = floor(fs / GYRO_FS);
offset = 10; % the offset between the two gyro recordings

gyro_1 = (downsample(original, n));
gyro_2 = (downsample(original(1+offset:end), n));
gyro_3 = (downsample(original(1+2*offset:end), n));
gyro_4 = (downsample(original(1+3*offset:end), n));

gyro_merged_13 = merge_signals(gyro_1, gyro_3, 1, 2, n);
gyro_merged_24 = merge_signals(gyro_2, gyro_4, 1, 2, n);
gyro_merged = merge_signals(gyro_merged_13, gyro_merged_24, 1, 2, n);
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

soundsc(filtered, fs);