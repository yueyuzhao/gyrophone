function correct_rate = test_svm_classifier
% Train an SVM classifier with the reduced TIDIGITS set

TRAIN_DIR = 'temp/train';
TEST_DIR = 'temp/test';
LABEL_IND = [5];

USE_PCA = false;
NUM_OF_COEFFS = 5;

[train_obj, train_features] = get_files_and_features(TRAIN_DIR, LABEL_IND);
[test_obj, test_features] = get_files_and_features(TEST_DIR, LABEL_IND);

% Remove NaNs from cells
%test_features.mfcc_delta.Std = remove_nans_from_cell(test_features.mfcc_delta.Std);
%test_features.mfcc_delta.Mean = remove_nans_from_cell(test_features.mfcc_delta.Mean);

train = [train_features.mfcc.Mean' train_features.mfcc.Std' train_features.mfcc_delta.Mean' train_features.mfcc_delta.Std' ...
         train_features.centroid.Mean' train_features.centroid.Std' ...
         train_features.rms.Mean' train_features.rms.Std'];
train_labels = get(train_obj, 'Label')';

test = [test_features.mfcc.Mean' test_features.mfcc.Std' test_features.mfcc_delta.Mean' test_features.mfcc_delta.Std' ...
        test_features.centroid.Mean' test_features.centroid.Std' ...
        test_features.rms.Mean' test_features.rms.Std'];
test_labels = get(test_obj, 'Label')';

% save features train train_labels test test_labels;
% load features;

if USE_PCA
    [~, train_pcvec] = pca(train);
    train_pcvec = train_pcvec(1:NUM_OF_COEFFS, :);
    train = train * train_pcvec';
    test = test * train_pcvec';
end

% s = svmtrain(train, train_labels);
% c = svmclassify(s, test);
c = multisvm(train, train_labels, test, 'tolkkt', 1e-2, 'kktviolationlevel', 0.1);
u = unique(train_labels);
display(['Number of unique labels: ' num2str(length(u))]);
correct = strcmp(u(c), test_labels);
% correct = strcmp(c, test_labels);
svm_correct_rate = sum(correct)/length(correct);
display(svm_correct_rate);

% classify using GMM
NUM_OF_GAUSSIANS = 10;
NUM_OF_ITERATIONS = 20;
[mu_train, sigma_train, c_train] = ...
    GMM.gmm_training(train', train_labels, NUM_OF_GAUSSIANS, ...
                     NUM_OF_ITERATIONS);                                  
c = GMM.gmm_classification(test', mu_train, sigma_train, c_train);
correct = strcmp(u(c), test_labels);
gmm_correct_rate = sum(correct)/length(correct);
display(gmm_correct_rate);

% classify using K-NN
K = 3; % number of neighbors to use
c = knnclassify(test, train, train_labels, K);
correct = strcmp(c, test_labels);
knn_correct_rate = sum(correct)/length(correct);
display(knn_correct_rate);

% classify using MIR
result = mirclassify(train_obj, {train_features.mfcc.Mean, train_features.mfcc.Std, train_features.centroid.Mean, train_features.centroid.Std}, ...
    test_obj, {test_features.mfcc.Mean, test_features.mfcc.Std, test_features.centroid.Mean, test_features.centroid.Std});
mir_correct_rate = get(result, 'Correct');
display(mir_correct_rate);

correct_rate = [svm_correct_rate, gmm_correct_rate, knn_correct_rate, ...
    mir_correct_rate]

end

function without_nans = remove_nans_from_cell(c)
    without_nans = c;
    len = length(c{1});
    without_nans(cellfun(@(x) all(isnan(x)), without_nans)) = mat2cell(zeros(len, 1));
    without_nans = cell2mat(without_nans);
end

function [audio_obj, features] = get_files_and_features(dir, l)
    current_dir = cd();
    cd(dir);
    % label according to l-th character in file name
    audio_obj = miraudio('Folder', 'Label', l, 'Normal');
%     features = mirfeatures('Folder', 'Stat');
    features = struct();
    mfcc = mirmfcc(audio_obj, 'Frame');
    features.mfcc = mirstat(mfcc);
    mfcc_delta = mirmfcc(audio_obj, 'Frame', 'Delta');
    features.mfcc_delta = mirstat(mfcc_delta);
    centroid = mircentroid(audio_obj, 'Frame');
    features.centroid = mirstat(centroid);
    rms = mirrms(audio_obj, 'Frame');
    features.rms = mirstat(rms);
    cd(current_dir);
end

function [svm_struct, groups] = train_svm(features, labels)
    groups = unique(labels);
    num_of_groups = length(groups);
%     num_of_samples = length(labels);
    svm_struct = cell(num_of_groups);
    
    for i = 1:num_of_groups
        for j = 1:num_of_groups
            i_features = features(cell2mat(labels) == groups{i}, :);
            
            if (j < i)
                j_features = features(cell2mat(labels) == groups{j}, :);
            else
                j_features = features(cell2mat(labels) ~= groups{i}, :);
            end;
            
            ij_features = [i_features; j_features];
            binary_labels = [ones(size(i_features,1), 1); zeros(size(j_features,1), 1)];
            svm_struct{i,j} = svmtrain(ij_features, binary_labels);
        end
    end
end

function class = classify_svm(svm_struct, features, groups)
    num_of_groups = length(svm_struct);
    num_of_samples = size(features, 1);
    labels = zeros(num_of_groups, num_of_groups, num_of_samples);
    
    for i = 1:num_of_groups
        for j = 1:num_of_groups
            labels(i, j, :) = svmclassify(svm_struct{i, j}, features);
        end
    end
    
    win_times = squeeze(sum(labels, 1));
    [~, class] = max(win_times);
    class = groups(class);
end