function [offset, original, reconstructed] = test_downsampled
% Test non-uniform reconstruction with downsampled signals
% [original, fs] = audioread('samples/chirp-120-160hz.wav');
[original, original_fs] = audioread('samples/goodbye.wav');

NUM_DEVICES = 3;
global GYRO_FS;
GYRO_FS = 200;

USE_ORIGINAL_OFFSET = true;
USE_ORIGINAL_TIMESKEW = true;
REFINE_OFFSET = false;
REFINE_TIMESKEW = false;

reconstruction_func = @sp_eldar_impl_n3;

original_ds = resample(original, GYRO_FS * NUM_DEVICES, original_fs);

fs = GYRO_FS * NUM_DEVICES;

% Using generated test signal
% original_ds = gen_test_signal(fs/2-100, fs, 500);

playsound(original_ds, fs);
fft_plot(original_ds, fs);
title('Original signal');

gyro = cell(NUM_DEVICES, 1);
estimated_offset = zeros(1, NUM_DEVICES);

% Generate random offsets
% original_offset = gen_random_offset(100, NUM_DEVICES, original_fs);
% original_offset = randi([1, 10], [1 NUM_DEVICES]);
original_offset = ones(1, NUM_DEVICES);
display(original_offset);

T = 1/GYRO_FS;
% original_timeskew = rand(1, NUM_DEVICES) * T;
original_timeskew = [0 0.3 0.7] * T;
original_timeskew = original_timeskew(1:NUM_DEVICES);
display(original_timeskew);

N0 = 0; % noise PSD

ds_factor = original_fs / fs; % downsampling
% calculating upsampled_offset: fist tranform into time
upsampled_offset = floor((original_offset + original_timeskew * fs) * ds_factor);

% Downsampling with random offset - simulate time-interleaved ADCs
for i=1:NUM_DEVICES
    gyro{i} = downsample(original(upsampled_offset(i):end), (original_fs/GYRO_FS));
    % We don't use normalization in the simulation, in case of a synthetic 
    % generated signal one of the DCs can sample only 0-s which
    % we don't want to normalize. Also, there is no need since
    % we sample the signal without simulating attenuation.
    gyro{i} = gyro{i} + N0*randn(size(gyro{i}));
end

for i=1:NUM_DEVICES
    estimated_offset(i) = round(find_offset(gyro{i}, GYRO_FS, original_ds, fs) / ds_factor);
end
display(estimated_offset);

%% Find time-skews
if USE_ORIGINAL_OFFSET
    offset = original_offset - min(original_offset);
else
    offset = estimated_offset - min(estimated_offset);
    if REFINE_OFFSET
        % find the shift in offset for which we get the 
        % maximum correlation with the original signal
        offset = refine_offset(fs, offset, 10, NUM_DEVICES, gyro, ...
            original_ds, reconstruction_func);
    end
end

trimmed = trim_signals(gyro, offset);

if USE_ORIGINAL_TIMESKEW
    time_skew = original_timeskew;
else
%     time_skew = offset_to_timeskew(offset, NUM_DEVICES, fs);
    time_skew = original_timeskew + rand(size(original_timeskew)) * 1e-4;
    display(time_skew);    
    if REFINE_TIMESKEW
        time_skew = refine_timeskew(time_skew, NUM_DEVICES, trimmed, ...
            original_ds, reconstruction_func);
    end
end

display(offset);
display(time_skew);
[reconstructed, reconstructed_fs] = reconstruction_func(GYRO_FS, trimmed, time_skew);

figure;
fft_plot(reconstructed, reconstructed_fs);
title('Merged from recordings');
playsound(reconstructed, fs);

minlen = min(length(reconstructed), length(original_ds));
noise = real(fft(reconstructed(1:minlen)) - fft(original_ds(1:minlen)));
signal_to_noise = snr(reconstructed, noise);
display(signal_to_noise);

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