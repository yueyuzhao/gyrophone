function [label, score] = ...
    gmm_classify_sample(mu_train, sigma_train, c_train, sample_features)
    % Classify a sample by choosing the model with the highest score.
    % label - The classification of the sample.
    % score - The model matching score.
    
    NUM_OF_SPEAKERS = size(mu_train, 3);
    all_scores = zeros(NUM_OF_SPEAKERS, 1);
    for k = 1:NUM_OF_SPEAKERS
        all_scores(k) = GMM.get_score_for_potential_speaker(sample_features, ...
            mu_train(:,:,k), sigma_train(:,:,k), c_train(:,k));
    end;
    
    [score, label] = max(all_scores);
end