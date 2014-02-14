function test_speaker_identification
    % Test speaker identification with TIDIGITS
    NUM_OF_GAUSSIANS = 8;
%     NUM_OF_ITERATIONS = 20;
    
    USE_CACHE = false;
    
    db = gendb('tidigits');
    db = filterdb(db, 'age', '1-Adults', 'type', 'MAN');
%     db = filterdb(db, 'device', '0094e779d7d1841f');
    speakers = get_speakers(db);
    
    if USE_CACHE
        load speaker_identification_features;
    else       
        [features, labels] = ...
            get_speaker_features_and_labels(db, 'speaker');
        save speaker_identification_features;
    end
    
    % choose random speakers
    SPEAKERS_NUM = 10;
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
    train_features = features(:, cp.training);
    test_features = features(:, cp.test);
    
    [mu_train, sigma_train, c_train] = ...
        GMM.gmm_training(train_features, train_labels, NUM_OF_GAUSSIANS, ...
                         NUM_OF_ITERATIONS);
                                  
    class = GMM.gmm_classification(test_features, mu_train, sigma_train, c_train);
%     class = multisvm(train_features', train_labels, test_features');
    class = train_labels(class);

    correct = class == test_labels;
    correct_rate = sum(correct)/length(correct);
    display(correct_rate);
end