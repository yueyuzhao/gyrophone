function [offset, original, reconstructed] = test_downsampled
% Test non-uniform reconstruction with downsampled signals
% [original, fs] = audioread('samples/chirp-120-160hz.wav');
[original, fs] = audioread('samples/goodbye.wav');

NUM_DEVICES = 4;
global GYRO_FS;
GYRO_FS = 200;

USE_ORIGINAL_OFFSET = true;

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
original_offset = gen_random_offset(100, NUM_DEVICES, fs);
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
time_skew = offset_to_timeskew(offset, NUM_DEVICES, fs);
display(time_skew);

gyro = trim_signals(gyro, offset);

[reconstructed, merged_fs] = eldar_reconstruction(GYRO_FS, gyro, time_skew);
% [gyro_merged, merged_fs] = papoulis_reconstruction(GYRO_FS, gyro, time_skew);
% gyro_merged = interleave_vectors(gyro);
% merged_fs = NUM_DEVICES * GYRO_FS;

figure;
fft_plot(reconstructed, merged_fs);
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

function playsound(samples, fs)
    PLAY_SOUNDS = true;
    MIN_SR = 1000;
    if PLAY_SOUNDS
        if (fs < MIN_SR)
            resampled = resample(samples, MIN_SR, fs);
            soundsc(resampled, MIN_SR);
        else
            soundsc(samples, fs);
        end
        pause;
    end
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