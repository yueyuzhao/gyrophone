function correct_rate = test_with_dtw(label_ind)
    TRAIN_DIR = 'temp/train';
    TEST_DIR = 'temp/test';
    mirverbose(0);
    
    % LABEL_IND specify the indices of the characters in the filename
    % that are taken as the label for that file
    LABEL_IND = label_ind;
    
    [train_obj, train_features] = get_files_and_stft_features(TRAIN_DIR, LABEL_IND);
    [test_obj, test_features] = get_files_and_stft_features(TEST_DIR, LABEL_IND);
    
    train_labels = get(train_obj, 'Label')';
    test_labels = get(test_obj, 'Label')';
    
    u = unique(train_labels);
    display(['Number of unique labels: ' num2str(length(u))]);
    class = cell(size(test_labels));
    for i = 1:length(test_labels)
        sample = test_features{i};
        class{i} = dtw_classify_sample(sample, train_features, train_labels);
    end
    
    correct = strcmp(class, test_labels);
    confusionmat(test_labels, class)
    classperf(test_labels, class)
    correct_rate = sum(correct)/length(correct);
    display(correct_rate);
end