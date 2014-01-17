function [mu, sigma, c] = ...
    gmm_estimate_of_speaker(speaker_features, num_of_gaussians, num_of_iter)
    cd ../../utils/GMM_files
    [mu, sigma, c] = gmm_estimate(speaker_features, num_of_gaussians, num_of_iter);
    cd ../../matlab/gmm
    
%     obj = gmdistribution.fit(speaker_features', num_of_gaussians, ...
%         'CovType', 'diagonal', 'Regularize', 1);
%     mu = obj.mu';
%     sigma = squeeze(obj.Sigma);
%     c = obj.PComponents;
end