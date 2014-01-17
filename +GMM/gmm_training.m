function [mu_train, sigma_train, c_train] = ...
    gmm_training(feature_matrix, labels, num_of_gaussians, num_of_iter)
    % Perform GMM modelling of each speaker
    
    NUM_OF_FEATURES = size(feature_matrix, 1);

    unique_labels = unique(labels);
    NUM_OF_SPEAKERS = length(unique_labels);
    
    mu_train = zeros(NUM_OF_FEATURES, num_of_gaussians, NUM_OF_SPEAKERS);
    sigma_train = zeros(NUM_OF_FEATURES, num_of_gaussians, NUM_OF_SPEAKERS);
    c_train = zeros(num_of_gaussians, NUM_OF_SPEAKERS);
    
    for k = 1:NUM_OF_SPEAKERS
        speaker_features = feature_matrix(:, labels == unique_labels(k));
        [mu, sigma, c] = gmm_estimate_of_speaker(speaker_features, num_of_gaussians, num_of_iter);
        mu_train(:, :, k) = mu;
        sigma_train(:, :, k) = sigma;
        c_train(:, k) = c;
    end;
end