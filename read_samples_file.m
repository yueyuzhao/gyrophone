function [timestamps, samples] = read_samples_file(filename)
    DATA_FORMAT = '%u64 %f %f %f';
    fid = fopen(filename, 'r');
    data = textscan(fid, DATA_FORMAT);
    fclose(fid);
    
    timestamps = data{1};
    samples = [data{2} data{3} data{4}];
end