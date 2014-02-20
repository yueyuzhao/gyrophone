function [mu, sigma, c] = ...
    gmm_estimate_of_speaker(features, num_of_gaussians, num_of_iter)
    [mu, sigma, c] = GMMImpl.gmm_estimate(features, num_of_gaussians, num_of_iter);
    
%     obj = gmdistribution.fit(speaker_features', num_of_gaussians, ...
%         'CovType', 'diagonal', 'Regularize', 1);
%     mu = obj.mu';
%     sigma = squeeze(obj.Sigma);
%     c = obj.PComponents;
end