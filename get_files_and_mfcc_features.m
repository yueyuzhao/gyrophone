function [audio_obj, features] = get_files_and_mfcc_features(input_dir, l, fn_filter)
    current_dir = cd();
    cd(input_dir);
    files = get_files_by_filter(fn_filter);
    % label according to l-th character in file name
    audio_obj = miraudio(files, 'Label', l, 'Normal');
    features = struct();
    mfcc = mirmfcc(audio_obj, 'Frame');
    features.mfcc = mirstat(mfcc);
    mfcc_delta = mirmfcc(audio_obj, 'Frame', 'Delta');
    features.mfcc_delta = mirstat(mfcc_delta);
    centroid = mircentroid(audio_obj, 'Frame');
    features.centroid = mirstat(centroid);
    rms = mirrms(audio_obj, 'Frame');
    features.rms = mirstat(rms);
    cd(current_dir);
end