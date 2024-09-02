% Filename: eg_model_LIF_SOM
% Date: 2024.7.24
% Author: Jiatong Guo
% Description:  LIF model with fixed connection, 400 neurons comprising 300 PCs, 50 PVs, 50 SOMs
%               An example of leak integrate and fire model. 
%               The model will run for 3s and return the rasterplot of the last 1000 ms.


%% Setting Path
addpath('module');
addpath('multi_band');
load('param2.mat');


%% Parameters for Model LIF
param2 = param;
param2.duration =  3;

alpha = 1;
beta = 10;

param2.ne = 300;
param2.ni = 50;
param2.ns = 50;

param2.M        = 100*beta; % threshold potential
param2.Mr       = 66*beta;  % rest potential

% probability of spike projections
p = 0.8;        
param2.p_ee = p;
param2.p_ei = p;
param2.p_ii = p;
param2.p_ie = p;
param2.p_se = p;
param2.p_es = p;
param2.p_is = p;

% param2.p_ee = 0.16;
% param2.p_ei = 0.411;
% param2.p_ii = 0.451;
% param2.p_ie = 0.395;
% param2.p_se = 0.182;
% param2.p_es = 0.424;
% param2.p_is = 0.857;


% synapic strength
% param2.s_ee     = 5*0.15/alpha*beta/p;
% param2.s_ie     = 2*0.5/alpha*beta/p;
% param2.s_ei     = 4.91*0.425/alpha*beta/p;
% param2.s_ii     = 4.91*0.40/alpha*beta/p;
% param2.s_es     =  /alpha*beta/p;
% param2.s_se     =  /alpha*beta/p;
% param2.s_is     =  /alpha*beta/p;
% param2.s_exe     = /alpha*beta/p;
% param2.s_exi     = /alpha*beta/p;
% param2.s_exs     = /alpha*beta/p;

param2.s_ee     = 0.36;
param2.s_ie     = 1.49;
param2.s_ei     = 0.48;
param2.s_ii     = 0.68;
param2.s_es     = 0.31;
param2.s_se     = 0.86;
param2.s_is     = 0.5;
param2.s_exe    = 1;
param2.s_exi    = 1;
param2.s_exs    = 1;


% synaptic timescale 
param2.tau_ie = 1.2;   % AMPA
param2.tau_ee = 1.4;    
param2.tau_ei = 4.5;   % GABA
param2.tau_ii = 4.5;
param2.tau_se = 1.2;
param2.tau_is = 4.5;
param2.tau_es = 4.5;

% frequency of exteranl input
param2.lambda_e = 7000;    
param2.lambda_i = 7000;
param2.lambda_s = 7000;


% instantiate model
tic;
res_lif = model_LIF_SOM(param2,[]);
toc;

figure;
rasterplot2(res_lif, param2);
% xlim([2000,3000]);