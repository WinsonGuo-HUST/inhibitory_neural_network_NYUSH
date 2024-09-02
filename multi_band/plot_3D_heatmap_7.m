% % Filename: plot_3D_heatmap_7
% % Date: 2024.8.21
% % Author: Jiatong Guo
% % Description: plot 3D heatmap of dominant frequency
% % X-axis:s2e_delay
% % Y-axis:s2i_delay
% % Z-axis:Dominant Freqency

function plot_3D_heatmap_7(param)

    fs = 10000;  % sample frequency (Hz)
    N = 8192;    % number of samples
    n = 0:N-1;   % sample indices
    f = n * fs / N;  % frequency axis
    freq_max = 100;  % upper limit of frequency for analysis

    % Initialize the delay ranges
    step = 0.5;
    s2e_delay_range = 1:step:10;
    s2i_delay_range = 1:step:10;
    
    % Preallocate the matrix to store dominant frequencies
    dominant_freq_matrix = zeros(length(s2i_delay_range), length(s2e_delay_range));
    
    % Loop through each combination of s2e_delay and s2i_delay
    for s2i_idx = 1:length(s2i_delay_range)
        for s2e_idx = 1:length(s2e_delay_range)
            param.s2i_delay = s2i_delay_range(s2i_idx);
            param.s2e_delay = s2e_delay_range(s2e_idx);
            
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
            dominant_freq_matrix(s2i_idx, s2e_idx) = dominant_freq;
        end
    end
    
    % Create the 3D surface plot
    [X, Y] = meshgrid(s2e_delay_range, s2i_delay_range);
    Z = dominant_freq_matrix;
    
    figure;
    surf(X, Y, Z, 'EdgeColor', 'none');
    xlabel('\tau^{delay}_{es} (ms)');
    ylabel('\tau^{delay}_{is} (ms)');
    zlabel('Dominant Frequency (Hz)');
    title(sprintf('3D Heatmap of Dominant Frequency, step = %.1f ms', step));
    set(gca, 'FontSize', 20);
    colormap(jet);
    colorbar;
    view(3);  % 3D view
    