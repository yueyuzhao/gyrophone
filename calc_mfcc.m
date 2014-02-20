function mfcc_features = calc_mfcc(wavdata, samp_rate)
	% MFCC extraction from samples
	FRAME_LEN = 512; % 20 ms for sampling rate of 200 Hz

	audio = miraudio(wavdata, samp_rate);
	frames = mirframe(audio, 'Length', FRAME_LEN, 'sp');
	frame_mfcc = mirmfcc(frames);
	mfcc_data = mirgetdata(frame_mfcc);
	mfcc_features = values_to_features(mfcc_data);
end