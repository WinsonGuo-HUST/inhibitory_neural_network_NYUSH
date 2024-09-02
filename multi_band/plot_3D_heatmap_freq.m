% % Filename: plot_3D_heatmap_freq (Version-1)
% % Date: 2024.8.20
% % Author: Jiatong Guo
% % Description: Z-axis:Freqency

function plot_3D_heatmap_freq(param)
    % Initialize the delay ranges
    step = 2;
    s2e_delay_range = 1:step:10;
    s2i_delay_range = 1:step:10;
    
    % Frequency range
    freq_range = param.frequency_range(1):param.frequency_range(2);
    num_freqs = length(freq_range);
    
    % Preallocate power matrix
    power_matrix = zeros(length(s2i_delay_range), length(s2e_delay_range), num_freqs);
    
    % Loop through each combination of s2e_delay and s2i_delay
    for s2i_idx = 1:length(s2i_delay_range)
        for s2e_idx = 1:length(s2e_delay_range)
            param.s2i_delay = s2i_delay_range(s2i_idx);
            param.s2e_delay = s2e_delay_range(s2e_idx);
            
            % Run the model
            res_lif = model_LIF_SOM(param, []);
            
            % Sum membrane potentials
            VE_sum = sum(res_lif.VE, 2);
            VI_sum = sum(res_lif.VI, 2);
            VS_sum = sum(res_lif.VS, 2);
            total_membrane_potential = VE_sum + VI_sum + VS_sum;
            
            % Perform FFT
            fft_result = fft(total_membrane_potential);
            power_spectrum = abs(fft_result(1:num_freqs)).^2;
            
            % Store the result in the power matrix
            power_matrix(s2i_idx, s2e_idx, :) = power_spectrum;
        end
    end
    
    % Create the 3D heatmap with frequency as the Z-axis and power as the color
    [X, Y] = meshgrid(s2e_delay_range, s2i_delay_range);
    figure;
    for freq_idx = 1:num_freqs
        Z = freq_range(freq_idx) * ones(size(X));
        C = squeeze(power_matrix(:, :, freq_idx));  % Color based on power
        surf(X, Y, Z, C, 'EdgeColor', 'none');
        hold on;
    end
    
    % Customize the plot
    colorbar;
    title('3D Heatmap of Power Spectrum');
    xlabel('\tau^{delay}_{es}');
    ylabel('\tau^{delay}_{is}');
    zlabel('Frequency (Hz)');
    view(3);
    set(gca, 'FontSize', 20);
    colormap(jet);
    hold off;
end
