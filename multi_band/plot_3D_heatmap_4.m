% % Filename: plot_3D_heatmap_4
% % Date: 2024.8.20
% % Author: Jiatong Guo
% % Description: scanning s2e_delay and frequency, combining results for all s2i_delay
% % Z-axis: Power

function plot_3D_heatmap_4(param)
    % Initialize the delay ranges
    step = 2;
    s2e_delay_range = 1:step:10;
    s2i_delay_range = 5:5;
    
    % Frequency range
    freq_range = param.frequency_range(1):param.frequency_range(2);
    num_freqs = length(freq_range);
    
    % Preallocate 3D power matrix for all s2i_delay values
    power_matrix_all = zeros(length(s2i_delay_range), length(s2e_delay_range), num_freqs);
    
    % Loop through each s2i_delay
    for s2i_idx = 1:length(s2i_delay_range)
        param.s2i_delay = s2i_delay_range(s2i_idx);
        
        % Calculate power for each s2e_delay
        for s2e_idx = 1:length(s2e_delay_range)
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
            
            % Store the result in the 3D power matrix
            power_matrix_all(s2i_idx, s2e_idx, :) = power_spectrum;
        end
    end
    
    % Create a 3D surface plot with X as s2e_delay, Y as frequency, and Z as power
    [X, Y] = meshgrid(s2e_delay_range, freq_range);
    figure;
    
    % Loop through s2i_delay_range to plot the surfaces
    for s2i_idx = 1:length(s2i_delay_range)
        Z = squeeze(power_matrix_all(s2i_idx, :, :))';  % Transpose to align dimensions correctly
        hold on;
        surf(X, Y, Z, 'EdgeColor', 'none');
    end
    
    % Customize the plot
    colorbar;
    title('3D Power Spectrum Heatmap');
    xlabel('\tau^{delay}_{es}');
    ylabel('Frequency (Hz)');
    zlabel('Power');
    view(3); % 3D view to show the surface plots
    set(gca, 'FontSize', 20);
    colormap(jet);
    hold off;
end
