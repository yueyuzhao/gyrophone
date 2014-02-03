function test_with_dtw
    TRAIN_DIR = 'temp/train';
    TEST_DIR = 'temp/test';
    
    % LABEL_IND specify the indices of the characters in the filename
    % that are taken as the label for that file
    LABEL_IND = [5];
    
    [train_obj, train_features] = get_files_and_features(TRAIN_DIR, LABEL_IND);
    [test_obj, test_features] = get_files_and_features(TEST_DIR, LABEL_IND);
    
    train_labels = get(train_obj, 'Label')';
    test_labels = get(test_obj, 'Label')';
    
    class = cell(size(test_labels));
    for i = 1:length(test_labels)
        sample = test_features{i};
        class{i} = dtw_classify_sample(sample, train_features, train_labels);
    end
    
    correct = strcmp(class, test_labels);
    correct_rate = sum(correct)/length(correct);
    display(correct_rate);
end

function [audio_obj, features] = get_files_and_features(dir, l)
    current_dir = cd();
    cd(dir);
    % label according to l-th character in file name
    audio_obj = miraudio('Folder', 'Label', l, 'Normal');
    a = mirgetdata(audio_obj);
    sr = get(audio_obj, 'Sampling');
    features = cell(length(a), 1);
    for i = 1:length(a)
        WINDOW = 512;
        WINDOW_OVERLAP = WINDOW * 0.75;
        features{i} = specgram(a{i}, WINDOW, sr{i}, WINDOW_OVERLAP);
%         features{i} = mfcc(a{i}, sr{i}, 512);
    end
    cd(current_dir);
end