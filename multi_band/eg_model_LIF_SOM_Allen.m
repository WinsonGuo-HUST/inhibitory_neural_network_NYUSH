% % Filename: eg_model_LIF_SOM_Allen (Version-1)
% % Date: 2024.8.28
% % Author: Jiatong Guo
% % Description:  LIF model with fixed connection, 1000 neurons comprising 850 PCs, 75 PVs, 75 SOMs
% %               Completely use Allen institute data 

%% Setting Path
addpath('module');
addpath('multi_band');
load('param2.mat');

%% Parameters for Model LIF
param_som = param;

param_som.duration =  10000;  % ms

param_som.s2e_delay = 3;   % ms, from SOM to E-cells
param_som.s2i_delay = 3;   % ms, from SOM to PV-cells

param_som.ne = 850;
param_som.ni = 75;
param_som.ns = 75;

param_som.M        = 100; % threshold potential (= 1)
param_som.Mr       = 66;  % rest potential (= -2/3)

%% refractory period
tau = 3;
param_som.tau_re = tau; 
param_som.tau_ri = tau;
param_som.tau_rs = tau;

%% probability of spike projections

% Original Allen institute data
% param_som.p_ee = 0.160;
% param_som.p_ei = 0.411; 
% param_som.p_ii = 0.451; 
% param_som.p_ie = 0.395;
% param_som.p_se = 0.182;
% param_som.p_es = 0.424; 
% param_som.p_is = 0.857; 
% param_som.p_si = 0.030; 

% Adjusted data to match the average number of connections of one neuron
param_som.p_ee = 0.433; 
param_som.p_ei = 0.509; 
param_som.p_ii = 0.738;
param_som.p_ie = 0.814; 
param_som.p_se = 0.438;
param_som.p_es = 0.320;
param_som.p_is = 1.000;
param_som.p_si = 0.049; 

%% synapic strength
external = 1; 
param_som.s_exe    = external;
param_som.s_exi    = external;
param_som.s_exs    = external;
 
big = 1;
param_som.s_ee     = 0.0195 *100 *big; % 0.0180
param_som.s_ie     = 0.0750 *100 *big; % 0.0750
param_som.s_ei     = 0.0240 *100 *big; % 0.0240
param_som.s_ii     = 0.0340 *100 *big; % 0.0340
param_som.s_si     = 0.0210 *100 *big; % 0.0210
param_som.s_es     = 0.0155 *100 *big; % 0.0155 % 0.0455
param_som.s_se     = 0.0430 *100 *big; % 0.0430
param_som.s_is     = 0.0250 *100 *big; % 0.0250

%% synaptic timescale
% % Allen Institute data-abandoned
% param_som.tau_ie = 2.8;   % AMPA
% param_som.tau_ee = 5.5;    
% param_som.tau_ei = 8.5;   % GABA
% param_som.tau_ii = 5.8;
% param_som.tau_se = 2.8; 
% param_som.tau_is = 5.8;
% param_som.tau_si = 5.8;
% param_som.tau_es = 8.5;

% % CHAOS paper data
param_som.tau_ie = 1.2;   % AMPA
param_som.tau_ee = 1.4;    
param_som.tau_ei = 4.5;   % GABA
param_som.tau_ii = 4.5;
param_som.tau_se = 1.2; 
param_som.tau_is = 4.5;
param_som.tau_si = 4.5;
param_som.tau_es = 4.5;


%% frequency of exteranl input
freq = 1000;    % Hz
param_som.lambda_e = freq;    
param_som.lambda_i = freq;
param_som.lambda_s = freq;

%% Create the directory to save images if it doesn't exist
output_dir = 'week-8';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% instantiate model
tic;
res_lif = model_LIF_SOM(param_som,[]);
toc;
% figure;
% rasterplot2(res_lif, param_som);
fft_plot(res_lif, param_som);

%% 3D Heatmap
% tic;
% plot_3D_heatmap_8(param_som);
% toc;

%% Scanning: s2i_delay
% param_som.s2e_delay = 5;   % ms, from SOM to PV-cells
% for s2i_delay = 1:10
%     param_som.s2i_delay = s2i_delay; 
%     
%     tic;
%     res_lif = model_LIF_SOM(param_som, []);
%     toc;
% 
%     figure;
%     set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
%     rasterplot2(res_lif, param_som);
%     
%     % Construct the file path & Save the figure
%     filename = sprintf('rasterplot_s2i_%d_s2e_%d.fig', param_som.s2i_delay, param_som.s2e_delay);
%     filepath = fullfile(output_dir, filename);
%     saveas(gcf, filepath);
% end


%% Scanning: s2e_delay
% param_som.s2i_delay = 5;   % ms, from SOM to PV-cells
% for s2e_delay = 10:5:30
%     param_som.s2e_delay = s2e_delay; 
%     
%     tic;
%     res_lif = model_LIF_SOM(param_som, []);
%     toc;
% 
%     figure;
%     set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
%     rasterplot2(res_lif, param_som);
%     
%     % Construct the file path & Save the figure
%     filename = sprintf('rasterplot_s2i_%d_s2e_%d.fig', param_som.s2i_delay, param_som.s2e_delay);
%     filepath = fullfile(output_dir, filename);
%     saveas(gcf, filepath);
% end