%%% Filename: spectrum
%%% Date: 2024.8.20
%%% Author: Jiatong Guo
%%% Description: Spectrogram of Firing events

%% Plot spike-frequency spectrum
param_som.sdbin                    = 2.5;
param_som.spectrogram_timewindow   = 200;
param_som.frequency_range          = [5,80];
param_som.grid                     = 1;

sd1     = spikedensity2(res_lif, param_som);
spec1   = spectrogram2(sd1.e, param_som);
num_sample = size(spec1, 2);
m_spec1 = mean(spec1, 2);

avg_mat = kron(eye(32),ones(10,1)/10);
q       = zeros(1,32);
avg_mat = [avg_mat; q; q];
s_spec1 = spec1 * avg_mat;
num_s   = size(s_spec1,2);

var_spec1 = sum((s_spec1 - m_spec1).^2,2);
se_spec1 = sqrt(var_spec1/num_s^2);
sm_spec1 = conv(m_spec1, ones(5,1)/5, "same");

m_spec1 = mean(spec1, 2);
% m_spec1 = conv(m_spec1, ones(3,1)/3, "same");

var_spec1 = sum((spec1 - m_spec1).^2,2);
se_spec1 = sqrt(var_spec1/num_sample^2);

%% Panel C: Spectrogram
fre  = param_som.frequency_range(1):1:param_som.frequency_range(2);
figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
errorbar(fre, sm_spec1, se_spec1);
% xlim([11,57]);
% ylim([2,400]);
xlabel('Freq (Hz)');
ylabel('Avg Spec ((spikes/sec)^2/Hz)');
legend('Period 1');
title('p =', param_som.p_ee);
set(gca,'fontsize',15,'fontname','Arial','YScale','log');
