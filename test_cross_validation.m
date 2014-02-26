function correct_rate = test_cross_validation(input_dir, label_ind, ...
    features_func, fn_filter)

	USE_CACHE = false;
    USE_DTW = false;

	if USE_CACHE
		load('features_and_labels', 'features', 'labels');
	else
	    [audio_obj, features] = features_func(input_dir, label_ind, fn_filter);
	    labels = get(audio_obj, 'Label')';
	    save('features_and_labels', 'features', 'labels');
    end
    
    cp = cvpartition(labels, 'leaveout');
    labels = nominal(labels);
    order = unique(labels);
    
    if ~USE_DTW
        features_mat = [features.mfcc.Mean' features.mfcc.Std' features.mfcc_delta.Mean' ...
            features.mfcc_delta.Std' ...
            features.centroid.Mean' features.centroid.Std' ...
            features.rms.Mean' features.rms.Std'];

        features_mat = prewhiten(features_mat);
    
        svm_classf = @(xtrain, ytrain, xtest)(multisvm(xtrain, ytrain, xtest, 'tolkkt', 1e-2, 'kktviolationlevel', 0.1));
        svm_mcr = crossval('mcr', features_mat, labels, 'predfun', svm_classf, 'partition', cp);
            
        conf_func = @(xtrain, ytrain, xtest, ytest) confusionmat(ytest, ...
                    svm_classf(xtrain, ytrain, xtest), 'order', order);
        svm_cnf = crossval(conf_func, features_mat, labels, 'partition', cp);
        svm_cnf = reshape(sum(svm_cnf),length(order),length(order))
        
        gmm_classf = @(xtrain, ytrain, xtest)(GMM.gmm_classification_test(xtrain', ytrain, xtest'));
        gmm_mcr = crossval('mcr', features_mat, labels, 'predfun', gmm_classf, 'partition', cp);
        conf_func = @(xtrain, ytrain, xtest, ytest) confusionmat(ytest, ...
                    gmm_classf(xtrain, ytrain, xtest), 'order', order);
        gmm_cnf = crossval(conf_func, features_mat, labels, 'partition', cp);
        gmm_cnf = reshape(sum(gmm_cnf),length(order),length(order))
        
        correct_rate = [1-svm_mcr 1-gmm_mcr];
    end
    
    if USE_DTW
        dtw_classf = @(xtrain, ytrain, xtest)(dtw_classify(xtrain, ytrain, xtest));
        dtw_mcr = crossval('mcr', features, labels, 'predfun', dtw_classf, 'partition', cp);
        correct_rate = 1 - dtw_mcr;
        
        conf_func = @(xtrain, ytrain, xtest, ytest) confusionmat(ytest, ...
                    dtw_classf(xtrain, ytrain, xtest), 'order', order);
        dtw_cnf = crossval(conf_func, features, labels, 'partition', cp);
        dtw_cnf = reshape(sum(dtw_cnf),length(order),length(order))
    end
end

function class = dtw_classify(xtrain, ytrain, xtest)
    class = nominal(size(xtest, 1));
    for i = 1:length(xtest)
        sample = xtest{i};
        class(i) = dtw_classify_sample(sample, xtrain, ytrain);
    end
    class = class';
end