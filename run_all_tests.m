function run_all_tests(input_dir, num_iter)
    %% Gender identification
    gender_mcr = get_mean_test_result(@test_svm_classifier, 1, num_iter, input_dir);
    gender_mcr_dtw = get_mean_test_result(@test_with_dtw, 1, num_iter, input_dir);
    
    %% Speaker identification
    % Mixed
    speaker_mcr_mixed = get_mean_test_result(@test_svm_classifier, [1 2], ...
        num_iter, input_dir);
    speaker_mcr_mixed_dtw = get_mean_test_result(@test_with_dtw, [1 2], ...
        num_iter, input_dir);
    
    % Male only speakers
    speaker_mcr_male = get_mean_test_result(@test_svm_classifier, [1 2], ...
        num_iter, input_dir, 'M*.wav');
    speaker_mcr_male_dtw = get_mean_test_result(@test_with_dtw, [1 2], ...
        num_iter, input_dir, 'M*.wav');
    
    % Female only speakers
    speaker_mcr_female = get_mean_test_result(@test_svm_classifier, [1 2], ...
        num_iter, input_dir, 'F*.wav');
    speaker_mcr_female_dtw = get_mean_test_result(@test_with_dtw, [1 2], ...
        num_iter, input_dir, 'F*.wav');
    
    %% Digit identification
    % Mixed
    digit_mcr_mixed = get_mean_test_result(@test_svm_classifier, 5, ...
        num_iter, input_dir);
    digit_mcr_mixed_dtw = get_mean_test_result(@test_with_dtw, 5, ...
        num_iter, input_dir);
    
    % Male only speakers
    digit_mcr_male = get_mean_test_result(@test_svm_classifier, 5, ...
        num_iter, input_dir, 'M*.wav');
    digit_mcr_male_dtw = get_mean_test_result(@test_with_dtw, 5, ...
        num_iter, input_dir, 'M*.wav');
    
    % Female only speakers
    digit_mcr_female = get_mean_test_result(@test_svm_classifier, 5, ...
        num_iter, input_dir, 'F*.wav');
    digit_mcr_female_dtw = get_mean_test_result(@test_with_dtw, 5, ...
        num_iter, input_dir, 'F*.wav');
    
    %% Report results
    display(gender_mcr);
    display(gender_mcr_dtw);
    display(speaker_mcr_mixed);
    display(speaker_mcr_mixed_dtw);
    display(speaker_mcr_male);
    display(speaker_mcr_male_dtw);
    display(speaker_mcr_female);
    display(speaker_mcr_female_dtw);
    display(digit_mcr_mixed);
    display(digit_mcr_mixed_dtw);
    display(digit_mcr_male);
    display(digit_mcr_male_dtw);
    display(digit_mcr_female);
    display(digit_mcr_female_dtw);
end