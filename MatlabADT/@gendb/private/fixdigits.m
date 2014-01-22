function Odb = fixdigits(db)
    % Update digit field in metadata to be based
    % only on first character
    Odb = db;
    
    for i = 1:length(db.enteries)
        Odb.enteries(i).digit = db.enteries(i).digit(1:end-1);
    end
end