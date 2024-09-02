% % Filename: eg_model_LIF_SOM (Version-5)
% % Date: 2024.8.19
% % Author: Jiatong Guo
% % Description:  LIF model with fixed connection, 400 neurons comprising 300 PCs, 50 PVs, 50 SOMs
% %               The model will run for 3s and return the rasterplot of the last 1000 ms.
% %               Transformed synaptic strength

%% Setting Path
addpath('module');
addpath('multi_band');
load('param2.mat');

%% Parameters for Model LIF
param_som = param;

param_som.duration =  1000;  % ms

param_som.s2e_delay = 5;   % ms, from SOM to E-cells
param_som.s2i_delay = 5;   % ms, from SOM to PV-cells

param_som.ne = 300;
param_som.ni = 50;
param_som.ns = 50;

param_som.M        = 100; % threshold potential (= 1)
param_som.Mr       = 66;  % rest potential (= -2/3)

%% refractory period
tau = 3;
param_som.tau_re = tau; 
param_som.tau_ri = 2;
param_som.tau_rs = tau;

%% probability of spike projections

% CHAOS data
% p = 0.8;        
% param_som.p_ee = p;
% param_som.p_ei = p;
% param_som.p_ii = p;
% param_som.p_ie = p;
% param_som.p_se = p;
% param_som.p_es = p;
% param_som.p_is = p;
% param_som.p_si = p;

% Original Allen institute data
param_som.p_ee = 0.160;
param_som.p_ei = 0.411; 
param_som.p_ii = 0.451; 
param_som.p_ie = 0.395;
param_som.p_se = 0.182;
param_som.p_es = 0.424; 
param_som.p_is = 0.857; 
param_som.p_si = 0.030; 

% Adjusted Allen institute data
% param_som.p_ee = 0.533; % 0.160
% param_som.p_ei = 0.411; % 0.411
% param_som.p_ii = 0.451; % 0.451
% param_som.p_ie = 0.220; % 0.395
% param_som.p_se = 0.182; % 0.182
% param_som.p_es = 0.424; % 0.424
% param_som.p_is = 0.857; % 0.857
% param_som.p_si = 0.030; % 0.030

%% synapic strength
external = 1; % CHAOS
param_som.s_exe    = external;
param_som.s_exi    = external;
param_som.s_exs    = external;

% param_som.s_ee     = 0.0200 *100  / param_som.p_ee;% 0.0180
% param_som.s_ie     = 0.0430 *100  / param_som.p_ie;% 0.0750
% param_som.s_ei     = 0.0240 *100  / param_som.p_ei;% 0.0240
% param_som.s_ii     = 0.0340 *100  / param_som.p_ii;% 0.0340
% param_som.s_si     = 0.0210 *000  / param_som.p_si;% 0.0210
% param_som.s_es     = 0.0255 *100  / param_som.p_es;% 0.0155
% param_som.s_se     = 0.0430 *100  / param_som.p_se;% 0.0430
% param_som.s_is     = 0.0250 *100  / param_som.p_is;% 0.0250
 
big = 1;
param_som.s_ee     = 0.0180 *100 *big; % 0.0180
param_som.s_ie     = 0.0750 *100 *big; % 0.0750
param_som.s_ei     = 0.0240 *100 *big; % 0.0240
param_som.s_ii     = 0.0340 *100 *big; % 0.0340
param_som.s_si     = 0.0210 *100 *big; % 0.0210
param_som.s_es     = 0.0155 *100 *big; % 0.0155 % 0.0455
param_som.s_se     = 0.0430 *100 *big; % 0.0430
param_som.s_is     = 0.0250 *100 *big; % 0.0250

% param_som.s_ee     = 5.00*0.150 / param_som.p_ee;
% param_som.s_ie     = 2.00*0.500 / param_som.p_ie;
% param_som.s_ei     = 4.91*0.480 / param_som.p_ei;
% param_som.s_ii     = 4.91*0.400 / param_som.p_ii;
% % param_som.s_si     = 4.91*0.400 / param_som.p_si;
% param_som.s_si     = 0;
% param_som.s_es     = 4.91*0.400 / param_som.p_es;
% param_som.s_se     = 2.00*0.500 / param_som.p_se;
% param_som.s_is     = 4.91*0.400 / param_som.p_is;

%% synaptic timescale 
% param_som.tau_ie = 2.8;   % AMPA
% param_som.tau_ee = 2.5;    
% param_som.tau_ei = 8.5;   % GABA
% param_som.tau_ii = 5.8;
% param_som.tau_se = 2.6; 
% param_som.tau_is = 5.8;
% param_som.tau_si = 5.8;
% param_som.tau_es = 8.5;

param_som.tau_ie = 1.2;   % AMPA
param_som.tau_ee = 1.4;    
param_som.tau_ei = 4.5;   % GABA
param_som.tau_ii = 4.5;
param_som.tau_se = 1.2; 
param_som.tau_is = 4.5;
param_som.tau_si = 4.5;
param_som.tau_es = 4.5;


%% frequency of exteranl input
freq = 7000;
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
figure;
rasterplot2(res_lif, param_som);
% fft_plot(res_lif, param_som);

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


