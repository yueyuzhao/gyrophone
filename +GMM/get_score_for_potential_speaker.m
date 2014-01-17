function score = get_score_for_potential_speaker(feature_vector, ...
    mu, sigma, c)
    cd ../../utils/GMM_files
    [IYM IY] = lmultigauss(feature_vector, mu, sigma, c);
    score = IY;
    cd ../../matlab/gmm
    
%     sz = size(sigma);
%     sigma = reshape(sigma, [1 sz]);
%     obj = gmdistribution(mu', sigma, c);
%     [P, score] = posterior(obj, feature_vector');
end