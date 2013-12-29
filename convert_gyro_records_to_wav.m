% Convert gyro recordings to WAV files
INPUT_DIR = 'gyro_results/Nexus/tidigits/04dc22d4dad7e4ce';
files = dir(INPUT_DIR);
OUTPUT_DIR = 'wav';
GYRO_FS = 200;

for i = 1:length(files)
    if files(i).isdir
        continue;
    end
    
    filename = [INPUT_DIR '/' files(i).name];
    gyro_record_to_wav(filename, OUTPUT_DIR, GYRO_FS);
end