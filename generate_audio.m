%% Generate audio for sound feedback analysis on a phone
function generate_audio(output_file)
    FS = 8000;  
    FREQS = [90];
    AUDIO_LEN = 10; % in seconds
    NUM_SAMPLES = AUDIO_LEN * FS;
    AMP = .5; % amplitude
    
    % generate audio
    samples = zeros(1, NUM_SAMPLES);
    for f = FREQS
        x = zeros(1, NUM_SAMPLES);
        for i=1:NUM_SAMPLES
            x(i) = AMP * sin(2 * pi * f * (i-1) / FS);
        end;
        samples = samples + x;
    end
    
    samples = normalize(samples, AMP);
    
    % show FFT
    delta = FS/NUM_SAMPLES;
    plot(-FS/2:delta:FS/2-delta, fftshift(abs(fft(samples))));
    
    % play audio
    player = audioplayer(samples, FS);
    play(player);
    pause(AUDIO_LEN);
    
    % save audio to file
    audiowrite(output_file, samples, FS);
end

function normalized = normalize(samples, max_amp)
    normalized = samples / (max(samples)/max_amp);
end