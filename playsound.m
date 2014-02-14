function playsound(samples, fs, varargin)
    PLAY_SOUNDS = true;
    if nargin > 2
       PLAY_SOUNDS = varargin{1}; 
    end
    
    MIN_SR = 1000;
    if PLAY_SOUNDS
        if (fs < MIN_SR)
            resampled = resample(samples, MIN_SR, fs);
            soundsc(resampled, MIN_SR);
        else
            soundsc(samples, fs);
        end
        pause;
    end
end