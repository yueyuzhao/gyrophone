function [ref_signal, refsig_fs, ref_signal_ds] = ...
    read_signal(sample_name, num_devices)

    global GYRO_FS;
    [ref_signal, refsig_fs] = audioread(['samples/' sample_name '.wav']);
    ref_signal_ds = resample(ref_signal, GYRO_FS * num_devices, refsig_fs);
    ref_signal_ds = normalization(ref_signal_ds);
    display(['Samples in ' sample_name ' (resampled): ' ...
        num2str(length(ref_signal_ds))]);
    figure;
    subplot(121);
    fft_plot(ref_signal_ds, GYRO_FS * num_devices);
    title([sample_name ' FFT']);

end