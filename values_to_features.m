function features = values_to_features(values)
	% Convert a time-series obtained from a sample to a feature using
	% different kind of statistics over the values and the derivatives

	mean_val = nanmean(values, 2);
	variance = nanvar(values, 0, 2);
	% feature_skewness = skewness(values(~isnan(values)));
	% feature_kurtosis = kurtosis(values(~isnan(values)));

	abs_delta = abs(values(:, 2:end) - values(:, 1:end-1));
	mean_delta = nanmean(abs_delta, 2);
	var_delta = nanvar(abs_delta, 0, 2);

	maximum = max(values, [], 2);
	minimum = min(values, [], 2);

	features = [mean_val; variance; ... 
	%           feature_skewness; feature_kurtosis; ...
                mean_delta; var_delta; maximum; minimum];
end