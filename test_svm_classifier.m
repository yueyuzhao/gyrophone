function [train, train_labels, test, test_labels] = test_svm_classifier
% Train an SVM classifier with the reduced TIDIGITS set

TRAIN_DIR = 'temp/train';
TEST_DIR = 'temp/test';
LABEL_IND = [1];

NUM_OF_COEFFS = 5;
USE_PCA = false;

[train_obj, train_features] = get_files_and_features(TRAIN_DIR, LABEL_IND);
[test_obj, test_features] = get_files_and_features(TEST_DIR, LABEL_IND);

train = [train_features.mfcc.Mean' train_features.mfcc.Std' train_features.centroid.Mean' train_features.centroid.Std'];
train_labels = get(train_obj, 'Label')';

test = [test_features.mfcc.Mean' test_features.mfcc.Std' test_features.centroid.Mean' test_features.centroid.Std'];
test_labels = get(test_obj, 'Label')';

save features train train_labels test test_labels;
% load features;

if USE_PCA
    [~, train_pcvec] = pca(train);
    train_pcvec = train_pcvec(:, 1:NUM_OF_COEFFS);
    train = train * train_pcvec;
    test = test * train_pcvec;
end

% [s, groups] = train_svm(train, train_labels);
% c = classify_svm(s, test, groups);
c = multisvm(train, train_labels, test);
u = unique(train_labels);
correct = strcmp(u(c), test_labels);
correct_rate = sum(correct)/length(correct);
display(correct_rate);

% classify using K-NN
K = 3; % number of neighbors to use
c = knnclassify(test, train, train_labels, K);
correct = strcmp(c, test_labels);
correct_rate = sum(correct)/length(correct);
display(correct_rate);

result = mirclassify(train_obj, {mfcc(train_obj), mfcc(train_obj, 'Delta'), centroid(train_obj)}, ...
    test_obj, {mfcc(test_obj), mfcc(test_obj, 'Delta'), centroid(test_obj)});

end

function [audio_obj, features] = get_files_and_features(dir, l)
    current_dir = cd();
    cd(dir);
    % label according to l-th character in file name
    audio_obj = miraudio('Folder', 'Label', l, 'Trim', 'Normal');
%     features = mirfeatures('Folder', 'Stat');
    features = struct();
    mfcc = mirmfcc(audio_obj, 'Frame');
    features.mfcc = mirstat(mfcc);
    centroid = mircentroid(audio_obj, 'Frame');
    features.centroid = mirstat(centroid);
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