function correct_rate = test_speaker_identification
    % Test speaker identification with TIDIGITS
    USE_CACHE = false;
    
    USE_GMM = true;
    USE_BINARYSVM = false;
    USE_MULTISVM = false;
    USE_DTW = false;
    
    db = gendb('tidigits_gyro');
    db = filterdb(db, 'age', '1-Adults');
    
    if USE_CACHE
        load('speaker_identification_features', 'features', 'labels');
    else       
        [features, labels] = ...
            get_speaker_features_and_labels(db, 'speaker');
        savesave('speaker_identification_features', 'features', 'labels');
    end
    
    db = filterdb(db, 'type', 'WOMAN');
%     db = filterdb(db, 'device', '0094e779d7d1841f');
    db = filterdb(db, 'device', '00a697fa469633a5');
    speakers = get_speakers(db);
    
    % choose random speakers
    SPEAKERS_NUM = 5;
    TOTAL_NUM = length(speakers);
    speaker_ids = randperm(TOTAL_NUM);
    speaker_ids = sort(speaker_ids(1:SPEAKERS_NUM));
    % set mask
    mask = false(size(labels));
    for i = 1:length(speaker_ids)
       mask(labels == speaker_ids(i)) = true;
    end
    % filter speakers
    features = features(:, mask);
    labels = labels(mask);
    
    % Choose train and test sets
    cp = cvpartition(labels, 'holdout', 0.1);
    train_labels = labels(cp.training);
    test_labels = labels(cp.test);
    
    if USE_GMM || USE_MULTISVM || USE_BINARYSVM
        train_features = cell2mat(features(cp.training));
        test_features = cell2mat(features(cp.test));
    end
    
    if USE_GMM
        NUM_OF_GAUSSIANS = 8;
        NUM_OF_ITERATIONS = 20;
        [mu_train, sigma_train, c_train] = ...
            GMM.gmm_training(train_features, train_labels, NUM_OF_GAUSSIANS, ...
                             NUM_OF_ITERATIONS);                                  
        class = GMM.gmm_classification(test_features, mu_train, sigma_train, c_train);
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

    if ~USE_DTW
        u = unique(train_labels);
        class = u(class);
    end
    
    correct = class == test_labels;
    correct_rate = sum(correct)/length(correct);
    display(correct_rate);
end