function class = gmm_classification_test(xtrain, ytrain, xtest)
    % Classify new points in the 'xtest' set using GMM matching
    % Each column in xtest represents a point to be classified.
    % Each column in xtrain contains a training sample.
    % ytrain - column vector.
    
    NUM_OF_GAUSSIANS = 10;
    NUM_OF_ITERATIONS = 20;
    [mu_train, sigma_train, c_train] = ...
        GMM.gmm_training(xtrain, ytrain, NUM_OF_GAUSSIANS, NUM_OF_ITERATIONS);
    
    NUM_OF_TEST_SAMPLES = size(xtest, 2);
    ind = zeros(NUM_OF_TEST_SAMPLES, 1);
    for k = 1:NUM_OF_TEST_SAMPLES
        [ind(k), ~] = GMM.gmm_classify_sample(mu_train, sigma_train, ...
            c_train, xtest(:, k));        
    end;
    
    u = unique(ytrain);
    class = u(ind);
end