function interleaved_vec = interleave_vectors(vectors)
    % Interleave multiple vectors element-by-element
    num_vectors = length(vectors);
    element_count = zeros(1, num_vectors);
    for i = 1:num_vectors
        element_count(i) = numel(vectors{i});
    end
    
    temp = cell(num_vectors, max(element_count));
    for i = 1:num_vectors
        temp(i, 1:element_count(i)) = num2cell(vectors{i});
    end
    
    interleaved_vec = [temp{:}];
end