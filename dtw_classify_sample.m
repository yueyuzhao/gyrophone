function class = dtw_classify_sample(sample, train_data, train_labels)
    u = unique(train_labels);

    % convert train_labels to cell in
    % case it's a matrix
    t = whos('train_labels');
    if strcmp(t.class, 'double')
       train_labels = mat2cell(train_labels, ones(1, length(train_labels)));
    end
    
    N = length(train_data);
    d = zeros(length(u), 1);
    
    for i = 1:N
        ind = strcmp(u, train_labels{i});
        d(ind) = d(ind) + get_dtw_distance(sample, train_data{i});
    end
    
    [min_d, class] = min(d);
    class = u(class);
    
    t = whos('u');
    if strcmp(t.class, 'cell')
        class = class{1};
    end
end

function d = get_dtw_distance(d1, d2)
    SM = simmx(abs(d1), abs(d2));
    [~, ~, D] = dpfast(1-SM);
    d = D(size(D,1), size(D,2));
end