function [audio_obj, features] = get_files_and_stft_features(input_dir, l, fn_filter)
    current_dir = cd();
    cd(input_dir);
    files = get_files_by_filter(fn_filter);
    % label according to l-th character in file name
    audio_obj = miraudio(files, 'Label', l, 'Normal');
    a = mirgetdata(audio_obj);
    sr = get(audio_obj, 'Sampling');
    features = cell(length(a), 1);
    for i = 1:length(a)
        f = calc_stft(a{i}, sr{i});
%         f = lpc(a{i});
%         f = analyze_samples(a{i}, sr{i});
        features{i} = f;
%         features{i} = mfcc(a{i}, sr{i}, 512);
    end
    cd(current_dir);
end