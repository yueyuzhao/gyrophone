function class = gmm_classification2(xtrain, ytrain, xtest, speakers_ids)
    % Classify new points in the 'xtest' set using GMM matching
    % Each column in xtest represents a point to be classified.
    % Each column in xtrain contains a training sample.
    % ytrain - column vector.
    
    global NUM_OF_GAUSSIANS;
    global NUM_OF_ITERATIONS;
    [mu_train, sigma_train, c_train] = ...
        gmm_training(xtrain, ytrain, NUM_OF_GAUSSIANS, NUM_OF_ITERATIONS);
    
    NUM_OF_TEST_SAMPLES = size(xtest, 2);
    ind = zeros(NUM_OF_TEST_SAMPLES, 1);
    for k = 1:NUM_OF_TEST_SAMPLES
        [ind(k), score] = gmm_classify_sample(mu_train, sigma_train, c_train, xtest(:, k));        
    end;
    class = speakers_ids(ind)';
end