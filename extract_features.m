function [features, num_of_success] = extract_features(db, func)
	% db - a database to extract the features from
	% func - a function that extracts the features for a single database entry

    TRIM_SILENCE = true;
    GYRO = true;
    
    NUM_OF_ENTRIES = length(db);
	GYRO_DIM = 1;
    FS = 8000;
	
    features = {};
	num_of_success = 0;
    
	for k = 1:NUM_OF_ENTRIES
		try
			[wavdata, samp_rate] = read(db, k);
			wavdata = (wavdata{1});
            if GYRO
                wavdata = wavdata(:, GYRO_DIM);
            end
            wavdata = resample(wavdata, FS, samp_rate);
            fs = FS;
            
            if TRIM_SILENCE
                if GYRO
                    % cut 0.5 second at the beginning and a second from the end
                    wavdata = wavdata(4000:end-8000);
                end
                [wavdata, nseg] = get_voiced_segments(wavdata, fs);
            else
                nseg = 1;
            end
			
            if nseg > 0
                num_of_success = num_of_success + 1;
                features{num_of_success} = func(wavdata, fs);
            end
		catch ME
			% print error source
			ME.stack(1)
		end
	end
end