function score = get_score_for_potential_speaker(feature_vector, ...
    mu, sigma, c)
    [IYM IY] = GMMImpl.lmultigauss(feature_vector, mu, sigma, c);
    score = IY;
    
%     sz = size(sigma);
%     sigma = reshape(sigma, [1 sz]);
%     obj = gmdistribution(mu', sigma, c);
%     [P, score] = posterior(obj, feature_vector');
end