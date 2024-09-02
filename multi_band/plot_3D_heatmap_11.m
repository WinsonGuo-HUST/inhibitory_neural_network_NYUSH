% % Filename: plot_3D_heatmap_11
% % Date: 2024.8.23
% % Author: Jiatong Guo
% % Description: plot 3D heatmap of dominant frequency
% % X-axis:S_es
% % Y-axis:S_is
% % Z-axis:Dominant Freqency

function plot_3D_heatmap_11(param)

    fs = 10000;  % sample frequency (Hz)
    N = 8192;    % number of samples
    n = 0:N-1;   % sample indices
    f = n * fs / N;  % frequency axis
    freq_max = 100;  % upper limit of frequency for analysis

    % Initialize the delay ranges
    step = 0.2;
    S_es_range = 1.55:step:5.50;
    S_is_range = 2.50:step:5.50;
    
    % Preallocate the matrix to store dominant frequencies
    dominant_freq_matrix = zeros(length(S_is_range), length(S_es_range));
    
    % Loop through each combination of S_es and S_is
    for S_is_idx = 1:length(S_is_range)
        for S_es_idx = 1:length(S_es_range)
            param.s_is = S_is_range(S_is_idx);
            param.s_es = S_es_range(S_es_idx);
            
            % Run the model
            tic;
            res_lif = model_LIF_SOM(param, []);
            toc;
    
            % Sum membrane potentials
            VE_sum = sum(res_lif.VE, 2);
            VI_sum = sum(res_lif.VI, 2);
            VS_sum = sum(res_lif.VS, 2);
            total_membrane_potential = VE_sum + VI_sum + VS_sum;
            total_membrane_potential = total_membrane_potential(1:N);
            
            % Perform FFT
            fft_result = fft(total_membrane_potential, N);
            fft_result = abs(fft_result) * 2 / N;
            fft_result = fft_result(1:ceil(freq_max / (fs / N)));
            f_limited = f(1:ceil(freq_max / (fs / N)));  % Corresponding frequencies
            fft_result(1) = 0;  % Remove DC component (f = 0 Hz)
            
            % Find the dominant frequency
            [~, max_idx] = max(fft_result);
            dominant_freq = f_limited(max_idx);
            
            % Store the dominant frequency in the matrix
            dominant_freq_matrix(S_is_idx, S_es_idx) = dominant_freq;
        end
    end
    
    % Create the 3D surface plot
    [X, Y] = meshgrid(S_es_range, S_is_range);
    Z = dominant_freq_matrix;
    
    figure;
    surf(X, Y, Z, 'EdgeColor', 'none');
    xlabel('S_{es} (0.01)');
    ylabel('S_{is} (0.01)');
    zlabel('Dominant Frequency (Hz)');
    title(sprintf('3D Heatmap of Dominant Frequency, step = %.1f', step));
    set(gca, 'FontSize', 20);
    colormap(jet);
    colorbar;
    view(3);  % 3D view
    