function combine_recordings(input_dir, output_dir, dim)
    EXT = '.wav';
    
    dir_entries = dir(input_dir);
    devices = dir_entries(arrayfun(@(s)(s.isdir && ~strcmp(s.name, '.') ...
        && ~strcmp(s.name, '..')), dir_entries));
    devices = arrayfun(@(s)(s.name), devices, 'UniformOutput', false);
    
    display(devices);
    files = dir2([input_dir filesep devices{1}], EXT);
    files = cellfun(@get_basename, files, 'UniformOutput', false)';
    
    samples = {};
    progressbar;
    for i = 1:length(files)
        for n = 1:length(devices)
            [samples{n}, fs] = audioread([input_dir filesep devices{n} ...
                filesep num2str(dim) filesep files{i}]);
        end
        [rec, rec_fs] = multi_source(samples, fs);
%         [rec, rec_fs] = dtw_interpolation(samples, fs);
%         TARGET_SR = 16000;
%         rec = resample(rec, TARGET_SR, rec_fs);
        audiowrite([output_dir filesep files{i}], rec, rec_fs);
        progressbar(i/length(files));
    end
end

function basename = get_basename(path)
    [~, filename, ext] = fileparts(path);
    basename = [filename, ext];
end