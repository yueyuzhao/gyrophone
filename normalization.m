function [normalized_sig] = normalization(x)
    zeromean = x - mean(x);
    normalized_sig = zeromean / std(zeromean);
end