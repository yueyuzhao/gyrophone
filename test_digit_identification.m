function test_digit_identification
    % Test speaker identification with TIDIGITS
    NUM_OF_GAUSSIANS = 10;
    NUM_OF_ITERATIONS = 20;
    
    USE_CACHE = true;
    
    db = gendb('tidigits_gyro');
    speakers = get_speakers(db);
    
    if USE_CACHE
        load features;
    else       
        [features, labels] = ...
            get_features_and_labels(db, speakers);
        save features;
    end
    
    labels = train_labels;
    features = train_features;
    
    % choose random speakers
    SPEAKERS_NUM = 20;
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
    
    cp = cvpartition(labels, 'holdout', 0.1);
    train_labels = labels(cp.training);
    test_labels = labels(cp.test);
    train_features = features(:, cp.training);
    test_features = features(:, cp.test);
    
    [mu_train, sigma_train, c_train] = ...
        GMM.gmm_training(train_features, train_labels, NUM_OF_GAUSSIANS, ...
                         NUM_OF_ITERATIONS);
                                  
    class = GMM.gmm_classification(test_features, mu_train, sigma_train, c_train);
    class = train_labels(class);
    correct = class == test_labels;
    correct_rate = sum(correct)/length(correct);
    display(correct_rate);
end