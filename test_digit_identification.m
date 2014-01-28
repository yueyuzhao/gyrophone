function test_digit_identification
    % Test speaker identification with TIDIGITS
%     NUM_OF_GAUSSIANS = 10;
%     NUM_OF_ITERATIONS = 20;
    
    USE_CACHE = false;
    
    db = gendb('tidigits_gyro');
    db = filterdb(db, 'device', '0094e779d7d1841f');
    
    if USE_CACHE
        load features;
    else       
        [features, labels] = get_field_features_and_labels(db, 'digit');
        save features;
    end
    
    % Choose train and test sets
    cp = cvpartition(labels, 'holdout', 0.4);
    train_labels = labels(cp.training);
    test_labels = labels(cp.test);
    train_features = features(:, cp.training);
    test_features = features(:, cp.test);
    
%     [mu_train, sigma_train, c_train] = ...
%         GMM.gmm_training(train_features, train_labels, NUM_OF_GAUSSIANS, ...
%                          NUM_OF_ITERATIONS);
                                  
%     class = GMM.gmm_classification(test_features, mu_train, sigma_train, c_train);
    
    class = multisvm(train_features', train_labels, test_features');
    u = unique(train_labels);
    class = u(class);
    correct = class == test_labels;
    correct_rate = sum(correct)/length(correct);
    display(correct_rate);
end