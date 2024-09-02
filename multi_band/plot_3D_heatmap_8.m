% % Filename: plot_3D_heatmap_8
% % Date: 2024.8.22
% % Author: Jiatong Guo
% % Description: plot dominant freqency of PC/PV/SOM respectively
% % X-axis:s2e_delay
% % Y-axis:s2i_delay
% % Z-axis:Dominant Freqency

function plot_3D_heatmap_8(param)

    fs = 10000;  % sample frequency (Hz)
    N = 8192;    % number of samples
    n = 0:N-1;   % sample indices
    f = n * fs / N;  % frequency axis
    freq_max = 150;  % upper limit of frequency for analysis

    % Initialize the delay ranges
    step = 0.5;
    s2e_delay_range = 1:step:10;
    s2i_delay_range = 1:step:10;
    
    % Preallocate the matrix to store dominant frequencies
    PC_dominant_freq_matrix = zeros(length(s2i_delay_range), length(s2e_delay_range));
    PV_dominant_freq_matrix = zeros(length(s2i_delay_range), length(s2e_delay_range));
    SOM_dominant_freq_matrix = zeros(length(s2i_delay_range), length(s2e_delay_range));
    
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
            
            % sample
            VE_sum = VE_sum(1:N);
            VI_sum = VI_sum(1:N);
            VS_sum = VS_sum(1:N);
            
            f_limited = f(1:ceil(freq_max / (fs / N)));     % Corresponding frequencies

            % Perform FFT
            PC_fft_result = fft(VE_sum, N);
            PC_fft_result = abs(PC_fft_result) * 2 / N;           % recover real amplitude
            PC_fft_result = PC_fft_result(1:ceil(freq_max / (fs / N)));   % chop
            PC_fft_result(1) = 0;                              % Remove DC component (f = 0 Hz)
            [~, max_idx] = max(PC_fft_result);                 % Find the dominant frequency
            dominant_freq = f_limited(max_idx);
            PC_dominant_freq_matrix(s2i_idx, s2e_idx) = dominant_freq; % Store 

            PV_fft_result = fft(VI_sum, N);
            PV_fft_result = abs(PV_fft_result) * 2 / N;           % recover real amplitude
            PV_fft_result = PV_fft_result(1:ceil(freq_max / (fs / N)));   % chop
            PV_fft_result(1) = 0;                              % Remove DC component (f = 0 Hz)
            [~, max_idx] = max(PV_fft_result);                 % Find the dominant frequency
            dominant_freq = f_limited(max_idx);
            PV_dominant_freq_matrix(s2i_idx, s2e_idx) = dominant_freq; % Store

            SOM_fft_result = fft(VS_sum, N);
            SOM_fft_result = abs(SOM_fft_result) * 2 / N;           % recover real amplitude
            SOM_fft_result = SOM_fft_result(1:ceil(freq_max / (fs / N)));   % chop
            SOM_fft_result(1) = 0;                              % Remove DC component (f = 0 Hz)
            [~, max_idx] = max(SOM_fft_result);                 % Find the dominant frequency
            dominant_freq = f_limited(max_idx);
            SOM_dominant_freq_matrix(s2i_idx, s2e_idx) = dominant_freq; % Store
        end
    end
    
    % Create the 3D surface plot
    [X, Y] = meshgrid(s2e_delay_range, s2i_delay_range);
    Z_PC = PC_dominant_freq_matrix;
    Z_PV = PV_dominant_freq_matrix;
    Z_SOM = SOM_dominant_freq_matrix;
    
    figure;
    surf(X, Y, Z_PC, 'EdgeColor', 'none');
    xlabel('\tau^{delay}_{es} (ms)');
    ylabel('\tau^{delay}_{is} (ms)');
    zlabel('Dominant Frequency (Hz)');
    title(sprintf('E-cells: 3D Heatmap of Dominant Frequency, step = %.1f ms', step));
    set(gca, 'FontSize', 20);
    colormap(jet);
    colorbar;
    view(3);  % 3D view
    
    figure;
    surf(X, Y, Z_PV, 'EdgeColor', 'none');
    xlabel('\tau^{delay}_{es} (ms)');
    ylabel('\tau^{delay}_{is} (ms)');
    zlabel('Dominant Frequency (Hz)');
    title(sprintf('PVs: 3D Heatmap of Dominant Frequency, step = %.1f ms', step));
    set(gca, 'FontSize', 20);
    colormap(jet);
    colorbar;
    view(3);  % 3D view

    figure;
    surf(X, Y, Z_SOM, 'EdgeColor', 'none');
    xlabel('\tau^{delay}_{es} (ms)');
    ylabel('\tau^{delay}_{is} (ms)');
    zlabel('Dominant Frequency (Hz)');
    title(sprintf('SOMs: 3D Heatmap of Dominant Frequency, step = %.1f ms', step));
    set(gca, 'FontSize', 20);
    colormap(jet);
    colorbar;
    view(3);  % 3D view

