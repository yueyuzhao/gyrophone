function d = get_dtw_distance(d1, d2)
    SM = simmx(abs(d1), abs(d2));
%     [~, ~, D] = dpfast(1-SM);
    [~, ~, D] = dp(1-SM);
    d = D(size(D,1), size(D,2));
end