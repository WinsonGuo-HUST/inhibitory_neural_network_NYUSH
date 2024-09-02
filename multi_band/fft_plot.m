% % Filename: fft_plot
% % Date: 2024.8.26
% % Author: Jiatong Guo
% % Description: Apply fft and plot the frequency spectrum
% % X-axis: Frequency
% % Y-axis: Amplitude

function fft_plot(res_lif, param)
    
    fs = 10000; % sample frequency
    N = 2^16;   % samples
    n = 0:N-1;
    f = n * fs/N; % frequency axis
    freq_max = 300; % upper limit of freqency

    % Sum membrane potentials
    VE_sum = sum(res_lif.VE, 2);
    VI_sum = sum(res_lif.VI, 2);
    VS_sum = sum(res_lif.VS, 2);
    total_membrane_potential = VE_sum + VI_sum + VS_sum;
    total_membrane_potential = total_membrane_potential(1:N);

    %% Time-domain plot
    figure;
    plot(n / 10, total_membrane_potential);
    xlim([1,N] / 10);
    ylabel('Total Membrane Potential of 400 neurons');
    xlabel('Time (ms)');
    title(sprintf('S_{es} = %.4f, S_{is} = %.4f, \\tau_{es}^{delay} = %d ms, \\tau_{is}^{delay} = %d ms', param.s_es / 100, param.s_is / 100, param.s2e_delay, param.s2i_delay), 'FontSize', 25);
    set(gca,'fontsize',15);
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

    % Perform FFT
    fft_result = fft(total_membrane_potential, N);
    fft_result = abs(fft_result) *2/N ;
    fft_result(1) = 0;  % Remove DC component (f = 0 Hz)

    %% Frequency-domain plot
    figure;
    plot(f(1:ceil(freq_max/(fs/N))), fft_result(1:ceil(freq_max/(fs/N))));
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    title(sprintf('S_{es} = %.4f, S_{is} = %.4f, \\tau_{es}^{delay} = %d ms, \\tau_{is}^{delay} = %d ms', param.s_es / 100, param.s_is / 100, param.s2e_delay, param.s2i_delay), 'FontSize', 25);
    set(gca,'fontsize',15);
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

    %% Energy Spectral Density (ESD) plot
    esd = (fft_result.^2) / fs;

    % Limit frequency to [1, freq_max] Hz
    f_limited = f(1:ceil(freq_max/(fs/N)));
    esd_limited = esd(1:ceil(freq_max/(fs/N)));

    % Plot ESD with logarithmic axes
    figure;
    loglog(f_limited, esd_limited); % Log-log plot
    xlabel('Frequency (Hz)');
    ylabel('ESD (Amplitude^2/Hz)');
    title(sprintf('Energy Spectral Density (ESD), \\tau_{es}^{delay} = %d ms, \\tau_{is}^{delay} = %d ms', param.s2e_delay, param.s2i_delay), 'FontSize', 25);
    set(gca, 'FontSize', 15);
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    grid on; % Optional: Adds grid to the log-log plot for better visibility