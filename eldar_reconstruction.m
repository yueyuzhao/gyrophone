function [output, fs] = eldar_reconstruction(inp_fs, input, time_skew)
    % Reconstruction of a signal from non-uniform samples
    
    N = length(time_skew); % number of samplers
    fs = inp_fs * N; % full sampling frequency
    T_Q = 1 / fs; % Nyquist sampling period
    T = N * T_Q; % single sampler period
    
    % index_mapping is used to reorded filters in case the first input 
    % signal is actually delayed comparing to the second and not vice versa
    [time_skew, index_mapping] = sort(time_skew);
    
    H = construct_filters(N, T, time_skew);
    
    filtered = cell(N, 1);
    for i = 1:N
        % upsampling - according to the interpolation identity
        upsampled_input = upsample(input{index_mapping(i)}, N);
        filtered{i} = filter(H{i}, 1, upsampled_input);
    end
    
    min_len = min(cellfun('length', filtered));
    filtered_mat = zeros(min_len, N);
    for i=1:N
       filtered_mat(:, i) = filtered{i}(1:min_len);
    end
    output = real(sum(filtered_mat, 2)); % sum filterbank outputs
end

function filter_value = get_filter_value(N, T, a, time_skew, p, t)
    tp = time_skew(p + 1);
    sine_product_elements = ones(N, 1);
    for q = 0:N-1
       if q == p
           continue;
       end
       
       tq = time_skew(q + 1);
       sine_product_elements(q+1) = sin(pi*(t + tp - tq)/T);
    end
    sine_product = prod(sine_product_elements);
    filter_value = a(p + 1) * sinc((t)/T) * sine_product;
end

function H = construct_filters(N, T, tau)
    a = build_coefficients(N, T, tau);
    
    TAPS = 48;
    Tq = T/N;
    H = cell(N, 1);
    for p = 0:N-1
        H{p+1} = zeros(TAPS, 1);
        tp = tau(p+1);
        for n = 0:TAPS-1
            t = (n*Tq - tp);
            H{p+1}(n+1) = get_filter_value(N, T, a, tau, p, t);            
        end
        
%         H{p+1}(tp/Tq+1) = 1;
        fvtool(H{p+1});
    end
end

function a = build_coefficients(N, T, tau)
    % compute a coefficients according to Sindhi-Prabhu
    a = ones(N, 1);
    for p = 1:N
        for q = 1:N
            if q ~= p
                a(p) = a(p) / sin(pi*(tau(p) - tau(q)) / T);
            end
        end
    end
end