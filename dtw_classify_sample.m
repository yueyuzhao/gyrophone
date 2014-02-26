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
        if strcmp(t.class, 'nominal')
            ind = u == train_labels(i);
        else
            ind = strcmp(u, train_labels{i});
        end
        d(ind) = d(ind) + get_dtw_distance(sample, train_data{i});
    end
    
    [~, class] = min(d);
    class = u(class);
    
    t = whos('u');
    if strcmp(t.class, 'cell')
        class = class{1};
    end
end