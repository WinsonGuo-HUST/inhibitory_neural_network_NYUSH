% % Filename: plot_3D_heatmap (Version-1)
% % Date: 2024.8.20
% % Author: Jiatong Guo
% % Description: Z-axis:Power

function plot_3D_heatmap(param)
    % Initialize the delay ranges
    step = 2;
    s2e_delay_range = 1:step:10;
    s2i_delay_range = 1:step:10;
    
    % Preallocate power matrix
    power_matrix = zeros(length(s2i_delay_range), length(s2e_delay_range), param.frequency_range(2) - param.frequency_range(1) + 1);
    
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
            fft_result      = fft(total_membrane_potential);
            power_spectrum  = abs(fft_result).^2;
            freq_range      = param.frequency_range(1):param.frequency_range(2);
            power_spectrum  = power_spectrum(freq_range);
            
            % Store the result in the power matrix
            power_matrix(s2i_idx, s2e_idx, :) = power_spectrum;
        end
    end
    
    % Plot the 3D heatmap
    [X, Y] = meshgrid(s2e_delay_range, s2i_delay_range);
    for freq_idx = 1:length(freq_range)
        Z = squeeze(power_matrix(:, :, freq_idx));
        figure;
        surf(X, Y, Z);
        colorbar;
        title(['Frequency = ', num2str(freq_range(freq_idx)), ' Hz']);
        xlabel('s2e\_delay');
        ylabel('s2i\_delay');
        zlabel('Power');
        set(gca,'fontsize',20);
    end
end
