% % Filename: plot_3D_heatmap_power (Version-1)
% % Date: 2024.8.20
% % Author: Jiatong Guo
% % Description: Z-axis:Power, only scan one parameter

function plot_3D_heatmap_power(param)
    % Initialize the delay ranges
    step = 2;
    s2e_delay_range = 1:step:10;
    s2i_delay_range = 1:step:10;
    
    % Frequency range
    freq_range = param.frequency_range(1):param.frequency_range(2);
    num_freqs = length(freq_range);
    
    % Preallocate power matrix
    power_matrix = zeros(length(s2e_delay_range), num_freqs);
    
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
            
            % Store the result in the power matrix
            power_matrix(s2e_idx, :) = power_spectrum;
        end
        
        % Create the heatmap
        [X, Y] = meshgrid(s2e_delay_range, freq_range);
        figure;
        surf(X, Y, power_matrix', 'EdgeColor', 'none');
        
        % Customize the plot
        colorbar;
        title(['Heatmap for \tau^{delay}_{is} = ', num2str(s2i_delay_range(s2i_idx))]);
        xlabel('\tau^{delay}_{es}');
        ylabel('Frequency (Hz)');
        zlabel('Power');
        view(3); % View from above to create a heatmap effect
        set(gca, 'FontSize', 20);
        colormap(jet);
    end
end
