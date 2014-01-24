function field_values = get_field(db, field_name)
    NUM_OF_ENTRIES = length(db);
    field_values = cell(NUM_OF_ENTRIES, 1);
    
    for k = 1:NUM_OF_ENTRIES
        metadata = getmeta(db, k);
        field_values{k} = metadata.(field_name);
    end;
    
    [field_values, ~] = unique(speakers);
end
