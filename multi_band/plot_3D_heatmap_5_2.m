% % Filename: plot_3D_heatmap_5_2
% % Date: 2024.8.22
% % Author: Jiatong Guo
% % Description: scanning s2e_delay, plot PC/PV/SOM respectively 
% % X-axis: s2e_delay
% % Y-axis: Frequency
% % Z-axis: Amplitude

function plot_3D_heatmap_5_2(param)
    
    fs = 10000; % sample frequency
    N = 8192;   % samples
    n = 0:N-1;
    f = n * fs/N; % frequency axis
    freq_max = 150; % upper limit of freqency

    % Initialize the delay ranges
    step = 2;
    s2e_delay_range = 1:step:10;
    
    % Preallocate the matrix to store FFT results for each s2e_delay
    freq_range = f(1:ceil(freq_max/(fs/N))); % Limit frequency to [1, 150] Hz
    PC_fft_matrix = zeros(length(s2e_delay_range), length(freq_range));
    PV_fft_matrix = zeros(length(s2e_delay_range), length(freq_range));
    SOM_fft_matrix = zeros(length(s2e_delay_range), length(freq_range));

    % Calculate power for each s2e_delay
    for s2e_idx = 1 : length(s2e_delay_range)
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

        % Perform FFT
        PC_fft_result = fft(VE_sum, N);
        PC_fft_result = abs(PC_fft_result) *2/N ;
        PC_fft_result(1) = 0;  % Remove DC component (f = 0 Hz)
        PC_fft_matrix(s2e_idx, :) = PC_fft_result(1:ceil(freq_max/(fs/N))); % Store

        PV_fft_result = fft(VI_sum, N);
        PV_fft_result = abs(PV_fft_result) *2/N ;
        PV_fft_result(1) = 0;  % Remove DC component (f = 0 Hz)
        PV_fft_matrix(s2e_idx, :) = PV_fft_result(1:ceil(freq_max/(fs/N))); % Store
        
        SOM_fft_result = fft(VS_sum, N);
        SOM_fft_result = abs(SOM_fft_result) *2/N ;
        SOM_fft_result(1) = 0;  % Remove DC component (f = 0 Hz)
        SOM_fft_matrix(s2e_idx, :) = SOM_fft_result(1:ceil(freq_max/(fs/N))); % Store

     end
    
     % Create the 3D surface plot
    [X, Y] = meshgrid(s2e_delay_range, freq_range);

    figure;
    surf(X, Y, PC_fft_matrix', 'EdgeColor', 'none');    % matrix transpose
    xlabel('\tau^{delay}_{es} (ms)');
    ylabel('Frequency (Hz)');
    zlabel('Amplitude');
    title(sprintf('E-cells: 3D Frequency Spectrum Heatmap, step = %.1f', step));
    set(gca, 'FontSize', 15);
    colormap(jet);
    colorbar;
    view(3); % 3D view

    figure;
    surf(X, Y, PV_fft_matrix', 'EdgeColor', 'none');
    xlabel('\tau^{delay}_{es} (ms)');
    ylabel('Frequency (Hz)');
    zlabel('Amplitude');
    title(sprintf('PV: 3D Frequency Spectrum Heatmap, step = %.1f', step));
    set(gca, 'FontSize', 15);
    colormap(jet);
    colorbar;
    view(3); % 3D view

    figure;
    surf(X, Y, SOM_fft_matrix', 'EdgeColor', 'none');
    xlabel('\tau^{delay}_{es} (ms)');
    ylabel('Frequency (Hz)');
    zlabel('Amplitude');
    title(sprintf('SOM: 3D Frequency Spectrum Heatmap, step = %.1f', step));
    set(gca, 'FontSize', 15);
    colormap(jet);
    colorbar;
    view(3); % 3D view
