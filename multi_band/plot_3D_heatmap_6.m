% % Filename: plot_3D_heatmap_6
% % Date: 2024.8.22
% % Author: Jiatong Guo
% % Description: scanning s2i_delay
% % X-axis: s2i_delay
% % Y-axis: Frequency
% % Z-axis: Amplitude

function plot_3D_heatmap_6(param)
    
    fs = 10000; % sample frequency
    N = 8192;   % samples
    n = 0:N-1;
    f = n * fs/N; % frequency axis
    freq_max = 180; % upper limit of freqency

    % Initialize the delay ranges
    step = 0.1;
    s2i_delay_range = 1:step:10;
    
    % Preallocate the matrix to store FFT results for each s2i_delay
    freq_range = f(1:ceil(freq_max/(fs/N))); % Limit frequency to [1, 150] Hz
    fft_matrix = zeros(length(s2i_delay_range), length(freq_range));

    % Calculate power for each s2i_delay
    for s2i_idx = 1 : length(s2i_delay_range)
        param.s2i_delay = s2i_delay_range(s2i_idx);
     
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

        %% Time-domain plot
%         figure;
%         plot(n / 10, total_membrane_potential);
%         xlim([1,N] / 10);
%         ylabel('Total Membrane Potential of 400 neurons');
%         xlabel('Time (ms)');
%         title(sprintf('S_{es} = %.4f, S_{is} = %.4f, \\tau_{es}^{delay} = %d ms, \\tau_{is}^{delay} = %d ms', param.s_es / 100, param.s_is / 100, param.s2i_delay, param.s2i_delay), 'FontSize', 25);
%         set(gca,'fontsize',15);
%         set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

        % Perform FFT
        fft_result = fft(total_membrane_potential, N);
        fft_result = abs(fft_result) *2/N ;
        fft_result(1) = 0;  % Remove DC component (f = 0 Hz)
        
        %% Store FFT result in the matrix (limit frequency to [1, 150] Hz)
        fft_matrix(s2i_idx, :) = fft_result(1:ceil(freq_max/(fs/N)));
        
        %% Frequency-domain plot
%         figure;
%         plot(f(1:ceil(freq_max/(fs/N))), fft_result(1:ceil(freq_max/(fs/N))));
%         xlabel('Frequency (Hz)');
%         ylabel('Amplitude');
%         title(sprintf('S_{es} = %.4f, S_{is} = %.4f, \\tau_{es}^{delay} = %d ms, \\tau_{is}^{delay} = %d ms', param.s_es / 100, param.s_is / 100, param.s2i_delay, param.s2i_delay), 'FontSize', 25);
%         set(gca,'fontsize',15);
%         set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

     end
    
    %% Create the 3D surface plot
    [X, Y] = meshgrid(s2i_delay_range, freq_range);
    figure;
    surf(X, Y, fft_matrix', 'EdgeColor', 'none');
    xlabel('\tau^{delay}_{ei} (ms)');
    ylabel('Frequency (Hz)');
    zlabel('Amplitude');
    title(sprintf('3D Frequency Spectrum Heatmap, step = %.1f ms', step));
    set(gca, 'FontSize', 15);
    colormap(jet);
    colorbar;
    view(3); % 3D view