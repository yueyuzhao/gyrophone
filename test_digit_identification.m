function correct_rate = test_digit_identification
    % Test speaker identification with TIDIGITS
    USE_CACHE = false;
    
    USE_GMM = false;
    USE_DTW = true;
    USE_MULTISVM = false;
    USE_BINARYSVM = false;
    
    if USE_CACHE
        load('tidigits_features', 'features', 'labels');
    else
%         db = gendb('tidigits');    
        db = gendb('tidigits_gyro');

        % Filter single digit entries
        db = filterdb(db, 'digit', '[1-9OZ][AB]');

%         db = filterdb(db, 'device', '0094e779d7d1841f');
        db = filterdb(db, 'device', '00a697fa469633a5');
        db = filterdb(db, 'type', 'MAN');
        
        display('Feature extraction...');
        [features, labels] = get_field_features_and_labels(db, 'digit');
%         [features, labels] = get_speaker_features_and_labels(db, 'digit');
        save('tidigits_features', 'features', 'labels');
    end
    
    % Choose train and test sets
    cp = cvpartition(labels, 'holdout', 0.1);
    train_labels = labels(cp.training);
    test_labels = labels(cp.test);
    
    if USE_GMM || USE_MULTISVM || USE_BINARYSVM
        train_features = cell2mat(features(cp.training));
        test_features = cell2mat(features(cp.test)); 
    end
    
    if USE_GMM
        class = GMM.gmm_classification2(train_features, train_labels, test_features);
    end
    
    if USE_MULTISVM
        class = multisvm(train_features', train_labels, test_features', ...
            'tolkkt', 1e-2, 'kktviolationlevel', 0.1);
    end
    
    if USE_BINARYSVM
        s = svmtrain(train_features', train_labels, ...
            'tolkkt', 1e-2, 'kktviolationlevel', 0.1);
        class = svmclassify(s, test_features');
    end

    if USE_DTW
        train_features = features(cp.training);
        test_features = features(cp.test);
        
        class = zeros(size(test_labels));
        display('Classifying...');
        progressbar;
        for i = 1:length(test_labels)
            sample = test_features{i};
            class(i) = dtw_classify_sample(sample, train_features, train_labels);
            progressbar(i/length(test_labels));
        end
    end

    if USE_BINARYSVM
        u = unique(train_labels);
        class = u(class);
    end
    
    correct = class == test_labels;
    correct_rate = sum(correct)/length(correct);
    display(correct_rate);
end