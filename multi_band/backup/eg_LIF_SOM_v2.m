% % Filename: eg_model_LIF_SOM
% % Date: 2024.7.30
% % Author: Jiatong Guo
% % Description:  LIF model with fixed connection, 400 neurons comprising 300 PCs, 50 PVs, 50 SOMs
% %               An example of leak integrate and fire model. 
% %               The model will run for 3s and return the rasterplot of the last 1000 ms.
% %               Transformed synaptic strength

%% Setting Path
addpath('module');
addpath('multi_band');
load('param2.mat');

%% Parameters for Model LIF
param_som = param;
param_som.duration =  0.3;  % s
param_som.som_delay = 5;   % ms

alpha = 1;
beta = 3;

param_som.ne = 300;
param_som.ni = 50;
param_som.ns = 50;

param_som.M        = 100 * beta; % threshold potential (= 1)
param_som.Mr       = 66 * beta;  % rest potential (= -2/3)

% probability of spike projections

p = 0.8;        
param_som.p_ee = p;
param_som.p_ei = p;
param_som.p_ii = p;
param_som.p_ie = p;
param_som.p_se = p;
param_som.p_es = p;
param_som.p_is = p;
param_som.p_si = p;

% param_som.p_ee = 0.160;
% param_som.p_ei = 0.411;
% param_som.p_ii = 0.451;
% param_som.p_ie = 0.395;
% param_som.p_se = 0.182;
% param_som.p_es = 0.424;
% param_som.p_is = 0.857;
% param_som.p_si = 0.857;


% synapic strength

% param_som.s_ee     = 0.018 *100/alpha*beta / param_som.p_ee;
% param_som.s_ie     = 0.075 *100/alpha*beta / param_som.p_ie;
% param_som.s_ei     = 0.024 *100/alpha*beta / param_som.p_ei;
% param_som.s_ii     = 0.034 *100/alpha*beta / param_som.p_ii;
% param_som.s_si     = 0.034 *100/alpha*beta / param_som.p_si;
% param_som.s_es     = 0.0155*100/alpha*beta / param_som.p_es;
% param_som.s_se     = 0.043 *100/alpha*beta / param_som.p_se;
% param_som.s_is     = 0.025 *100/alpha*beta / param_som.p_is;
% param_som.s_exe    = 1;
% param_som.s_exi    = 1;
% param_som.s_exs    = 1;

% param_som.s_ee     = 0.018 *100/alpha*beta;
% param_som.s_ie     = 0.075 *100/alpha*beta;
% param_som.s_ei     = 0.024 *100/alpha*beta;
% param_som.s_ii     = 0.034 *100/alpha*beta;
% param_som.s_si     = 0.034 *100/alpha*beta;
% param_som.s_es     = 0.0155*100/alpha*beta;
% param_som.s_se     = 0.043 *100/alpha*beta;
% param_som.s_is     = 0.025 *100/alpha*beta;
% param_som.s_exe    = 1;
% param_som.s_exi    = 1;
% param_som.s_exs    = 1;

param_som.s_ee     = 5.00*0.150 /alpha*beta / param_som.p_ee;
param_som.s_ie     = 2.00*0.500 /alpha*beta / param_som.p_ie;
param_som.s_ei     = 4.91*0.400 /alpha*beta / param_som.p_ei;
param_som.s_ii     = 4.91*0.400 /alpha*beta / param_som.p_ii;
param_som.s_si     = 4.91*0.400 /alpha*beta / param_som.p_si;
param_som.s_es     = 4.91*0.400 /alpha*beta / param_som.p_es;
param_som.s_se     = 3.00*0.500 /alpha*beta / param_som.p_se;
param_som.s_is     = 4.91*0.400 /alpha*beta / param_som.p_is;
param_som.s_exe    = 1;
param_som.s_exi    = 1;
param_som.s_exs    = 1;

% param_som.s_ee     = 5.00*0.15 /alpha*beta ;
% param_som.s_ie     = 2.00*0.5   /alpha*beta;
% param_som.s_ei     = 4.91*0.416 /alpha*beta;
% param_som.s_ii     = 4.91*0.40  /alpha*beta;
% param_som.s_si     = 4.91*0.40  /alpha*beta;
% param_som.s_es     = 4.91*0.416 /alpha*beta;
% param_som.s_se     = 2.00*0.5   /alpha*beta;
% param_som.s_is     = 4.91*0.40  /alpha*beta;
% param_som.s_exe    = 1;
% param_som.s_exi    = 1;
% param_som.s_exs    = 1;

% synaptic timescale 
param_som.tau_ie = 1.2;   % AMPA
param_som.tau_ee = 1.4;    
param_som.tau_ei = 4.5;   % GABA
param_som.tau_ii = 4.5;
param_som.tau_se = 1.2;
param_som.tau_is = 4.5;
param_som.tau_si = 4.5;
param_som.tau_es = 4.5;

% refractory period
param_som.tau_re = 3; 
param_som.tau_ri = 3;
param_som.tau_rs = 3;

% frequency of exteranl input
param_som.lambda_e = 7000*beta;    
param_som.lambda_i = 7000*beta;
param_som.lambda_s = 7000*beta;

% instantiate model
tic;
res_lif = model_LIF_SOM(param_som,[]);
toc;

figure;
rasterplot2(res_lif, param_som);
ylim([0,400]);
% xlim([2000,3000]);