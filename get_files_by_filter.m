function files = get_files_by_filter(fn_filter)
    g = @(s)(s.('name'));
    files = arrayfun(g, dir(fn_filter), 'UniformOutput', false);
end