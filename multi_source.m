function [reconstructed, reconstructed_fs] = multi_source(samples, gyro_fs)
% Reconstruct signal from multiple sources

% DEVICES = {'00a697fa469633a5', '0094e779d7d1841f', '015d3fb673180c13', '04dc22d4dad7e4ce'};
num_devices = length(samples);
fs = num_devices * gyro_fs;

REFINE_TIMESKEW = false;
USE_APPROX_OFFSET = false;

% reconstruction_func = @sp_eldar_impl;
% reconstruction_func = @eldar_reconstruction;
reconstruction_func = @simple_interleaving;

dim = 1; % Gyro dimension to use

offset = zeros(1, num_devices);

%% Read recorded samples
% all_rec_plot = figure;
% title('All recordings');
% hold all;
for i = 1:num_devices
    display([num2str(length(samples{i})) ' samples in Gyro ' num2str(i) ' recording']);
    samples{i} = normalization( samples{i}(:, dim) );
% %     figure;
% %     fft_plot(samples{i}, GYRO_FS);
%     title(['Gyro ' num2str(i) ' samples']);
%     figure(all_rec_plot);
%     plot(samples{i});
end
% legend(DEVICES{1:NUM_DEVICES});

%% Find approximate offset based on timestamps
% approximate_offset = get_approximate_offset(timestamps, gyro_fs)';
% display(approximate_offset);

if USE_APPROX_OFFSET
%     offset = approximate_offset;
else
    %% Find the offset at which the reference signal appears in
    % each recording
    for i = 2:num_devices
        offset(i) = find_offset_multi_source(samples{1}, samples{i});
    end
    % set minimal offset to 0 - prevent negative offsets
    offset = offset - min(offset);
    display(offset);
end

% time_skew = offset_to_timeskew([0 (fs/num_devices+1)], num_devices, fs);
Tq = 1/fs;
time_skew = [0 1] * Tq;
trimmed = trim_signals(samples, offset);

if REFINE_TIMESKEW
    time_skew = refine_timeskew_multi_source(time_skew, num_devices, trimmed, ...
            reconstruction_func);
end

[reconstructed, reconstructed_fs] = reconstruction_func(gyro_fs, trimmed, time_skew);

% figure;
% fft_plot(reconstructed, reconstructed_fs);
% title('Merged from Gyro recordings');
% playsound(reconstructed, reconstructed_fs);

end

function [output, fs] = simple_interleaving(gyro_fs, input, time_skew)
    [~, index_mapping] = sort(time_skew);
    output = interleave_vectors(input(index_mapping));
    fs = gyro_fs * length(input);
end