function [normalized_sig] = normalization(x)
    normalized_sig = (x - mean(x)) / std(x);
end