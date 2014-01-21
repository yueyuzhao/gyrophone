function speakers = get_speakers(db)
    NUM_OF_ENTRIES = length(db);
    speakers = cell(NUM_OF_ENTRIES, 1);
    
    for k = 1:NUM_OF_ENTRIES
        metadata = getmeta(db, k);
        speakers{k} = metadata.speaker;
    end;
    
    [speakers, m] = unique(speakers);
end
