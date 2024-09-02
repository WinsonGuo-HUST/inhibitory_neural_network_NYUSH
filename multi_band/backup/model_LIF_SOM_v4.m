%%% Filename: model_LIF_SOM
%%% Date: 2024.8.7
%%% Author: Jiatong Guo
%%% Description: 
%%% LIF model with fixed connection, 400 neurons comprising 300 PCs, 50 PVs, 50 SOMs
%%% Add the delay of som_inhibition to PV
%%% Add connections from PV to SOM

function [res] = model_LIF_SOM(param,init)

%%% parameter sets 
% e:excitatory, i:inhibitory, s:somatostain
ne      = param.ne;     % number of cells
ni      = param.ni;
ns      = param.ns;
p_ee    = param.p_ee;   % projection probability
p_ie    = param.p_ie;
p_ei    = param.p_ei;
p_ii    = param.p_ii;
p_se    = param.p_se;
p_es    = param.p_es;
p_is    = param.p_is;
p_si    = param.p_si;
s_ee    = param.s_ee;   % synaptic strength
s_ie    = param.s_ie;
s_ei    = param.s_ei;
s_ii    = param.s_ii;
s_se    = param.s_se;
s_is    = param.s_is;
s_si    = param.s_si;
s_es    = param.s_es;
s_exe   = param.s_exe;
s_exi   = param.s_exi;
s_exs   = param.s_exs;
tau_ee  = param.tau_ee;     % time constant
tau_ie  = param.tau_ie;
tau_ei  = param.tau_ei;
tau_ii  = param.tau_ii;
tau_se  = param.tau_se;
tau_is  = param.tau_is;
tau_si  = param.tau_si;
tau_es  = param.tau_es;
dt      = param.gridsize;
tau_re   = param.tau_re;     % refractory period
tau_ri   = param.tau_ri;
tau_rs   = param.tau_rs;
M       = param.M;      % spike threshold
Mr      = param.Mr;     % inhibitory reversal potential
duration = param.duration; % ms
lambda_e = param.lambda_e/1000; % external spike frequency
lambda_i = param.lambda_i/1000;
lambda_s = param.lambda_s/1000;

delay           = 2;
flag_off_time   = 0.0;
start_threshold = 2;
end_threshold   = 2;
MFE_interval    = 1;
flag_time       = 0;

% time delay of dendritic inhibition
s2e_delay = param.s2e_delay;            % time delay for dendritic inhibition from SOM cells
s2i_delay = param.s2i_delay;
s2e_delay_steps = ceil( s2e_delay / dt);    % transfer time delay to steps
s2i_delay_steps = ceil( s2i_delay / dt);
s2e_inhibition_buffer = zeros(s2e_delay_steps, ne);
s2i_inhibition_buffer = zeros(s2i_delay_steps, ni);


% generate connection between neurons
connection_matrix_e=zeros(ne,ne+ni+ns);
connection_matrix_i=zeros(ni,ne+ni+ns);
connection_matrix_s=zeros(ns,ne+ni+ns);
connection_matrix_e(:,1:ne)             = binornd(1,p_ee,ne,ne);  % from e to e
connection_matrix_i(:,1:ne)             = binornd(1,p_ei,ni,ne);  % from i to e
connection_matrix_e(:,ne+1:ne+ni)       = binornd(1,p_ie,ne,ni);  % from e to i
connection_matrix_e(:,ne+ni+1:ne+ni+ns) = binornd(1,p_se,ne,ns);  % from e to s
connection_matrix_i(:,ne+1:ne+ni)       = binornd(1,p_ii,ni,ni);  % from i to i
connection_matrix_i(:,ne+ni+1:ne+ni+ns) = binornd(1,p_si,ni,ns);  % from i to s
connection_matrix_s(:,ne+1:ne+ni)       = binornd(1,p_is,ns,ni);  % from s to i
connection_matrix_s(:,1:ne)             = binornd(1,p_es,ns,ne);  % from s to e
connection_mat = [connection_matrix_e; connection_matrix_i; connection_matrix_s];
connection_mat(logical(eye(ne+ni+ns))) = 0;    % eliminate self-connection
connection_matrix_e = connection_mat(1:ne,:);
connection_matrix_i = connection_mat(ne+1:ne+ni,:);
connection_matrix_s = connection_mat(ne+ni+1:ne+ni+ns,:);


% determine External Spike Interval according to lambda
% row: external spike;  column: neuron index
esi_e = exprnd(1/lambda_e,ceil(lambda_e*(duration*1.4)),ne); 
esi_i = exprnd(1/lambda_i,ceil(lambda_i*(duration*1.4)),ni);
esi_s = exprnd(1/lambda_s,ceil(lambda_s*(duration*1.4)),ns);

while min(sum(esi_e))<duration || min(sum(esi_i))<duration || min(sum(esi_s))<duration  % ensure the total time of external spike series > duration
    esi_e = exprnd(1/lambda_e,ceil(lambda_e*(duration*1.4)),ne); 
    esi_i = exprnd(1/lambda_i,ceil(lambda_i*(duration*1.4)),ni); 
    esi_s = exprnd(1/lambda_s,ceil(lambda_s*(duration*1.4)),ns);
end


% convert esi to the external effect at each time point.
ex_e = zeros(duration/dt,ne);
ex_i = zeros(duration/dt,ni);
ex_s = zeros(duration/dt,ns);
for i=1:ne      % neuron index
    t=esi_e(1,i);
    count=1;    % spike index
    while t<duration
        ind = ceil(t/dt);
        ex_e(ind,i) = ex_e(ind,i) + exp((t-ind*dt)/tau_ee)/tau_ee;
        count=count+1;
        t = t+esi_e(count,i);
    end
end
for i=1:ni
    t=esi_i(1,i);
    count=1;
    while t<duration
        ind=ceil(t/dt);
        ex_i(ind,i)=ex_i(ind,i)+exp((t-ind*dt)/tau_ie)/tau_ie;
        count=count+1;
        t=t+esi_i(count,i);
    end
end
for i=1:ns
    t=esi_s(1,i);
    count=1;
    while t<duration
        ind=ceil(t/dt);
        ex_s(ind,i)=ex_s(ind,i)+exp((t-ind*dt)/tau_se)/tau_se;
        count=count+1;
        t=t+esi_i(count,i);
    end
end

qe=exp(-dt/tau_ee);
qi=exp(-dt/tau_ie);
qs=exp(-dt/tau_se);

for i=2:size(ex_e,1)
    ex_e(i,:)=ex_e(i,:)+ex_e(i-1,:)*qe; % consider the smearing effect of each spike
    ex_i(i,:)=ex_i(i,:)+ex_i(i-1,:)*qi;
    ex_s(i,:)=ex_s(i,:)+ex_s(i-1,:)*qs;
end



if isempty(init)
    ve=zeros(1,ne); % membrane potential
    vi=zeros(1,ni);
    vs=zeros(1,ns);
    he=zeros(3,ne); % row1: excitation; row2: PV inhibition;   row3: SOM inhibition (dendritic)
    hi=zeros(3,ni); % row1: excitation; row2: PV inhibition;   row3: SOM inhibition (dendritic)
    hs=zeros(2,ns); % row1: excitation; row2: PV inhibition;
else
    ve=init.ve;
    vi=init.vi;
    vs=init.vs;
    he=init.he;
    hi=init.hi;
    hs=init.hs;
end


res.HE          = zeros(ceil(duration/dt)+1,ne+ni+ns);
res.HI          = zeros(ceil(duration/dt)+1,ne+ni+ns);
res.HS          = zeros(ceil(duration/dt)+1,ne+ni);
res.VE          = zeros(ceil(duration/dt)+1,ne);
res.VI          = zeros(ceil(duration/dt)+1,ni);
res.VS          = zeros(ceil(duration/dt)+1,ns);
res.spikecount_e= zeros(ceil(duration/dt)+1,1);
res.spikecount_i= zeros(ceil(duration/dt)+1,1);
res.spikecount_s= zeros(ceil(duration/dt)+1,1);
res.MFE_time    = zeros(ceil(duration)+1,   2);
res.HEE_stat    = zeros(ceil(duration)+1,   3);

MFE_time2       = zeros(ceil(duration)+1,2);
HEE_stat2       = zeros(ceil(duration)+1,3);
wave_spike_count2 = zeros(1,ceil(duration)+1);
wave_spike_count = zeros(1,ceil(duration)+1);
wave_record     = zeros(1,100000);
wave_count      = 1;

refc_e  =zeros(1,ne);   % reference clock, represents the time since last spike
refc_i  =zeros(1,ni);
refc_s  =zeros(1,ns);
sl  =   duration;

spike_row = sl * 10;
spike_e = zeros(spike_row,ne);
spike_i = zeros(spike_row,ni);
spike_s = zeros(spike_row,ns);
nearray = 0:ne-1;
niarray = 0:ni-1;
nsarray = 0:ns-1;

flag = 0;   % wave data processing flag

for step = 2:duration/dt
    time = step*dt;

    rind_e= abs(refc_e)<10^-7; % reference index, if ture, the neuron can spike, else in refactory period
    rind_i= abs(refc_i)<10^-7;
    rind_s= abs(refc_s)<10^-7;
    refc_e(~rind_e)=refc_e(~rind_e) - dt; % for neurons still in refractory period
    refc_i(~rind_i)=refc_i(~rind_i) - dt;
    refc_s(~rind_s)=refc_s(~rind_s) - dt;
    
    % membrane potential update
    ve(rind_e)= ve(rind_e) + dt * (ex_e(step,rind_e)*s_exe + s_ee*he(1,rind_e)/tau_ee - s_ei*he(2,rind_e)/tau_ei.*(ve(rind_e)+Mr)/(M+Mr) - s_es*he(3,rind_e)/tau_es.*(ve(rind_e)+Mr)/(M+Mr));
    vi(rind_i)= vi(rind_i) + dt * (ex_i(step,rind_i)*s_exi + s_ie*hi(1,rind_i)/tau_ie - s_ii*hi(2,rind_i)/tau_ii.*(vi(rind_i)+Mr)/(M+Mr) - s_is*hi(3,rind_i)/tau_is.*(vi(rind_i)+Mr)/(M+Mr));
    vs(rind_s)= vs(rind_s) + dt * (ex_s(step,rind_s)*s_exs + s_se*hs(1,rind_s)/tau_se - s_si*hs(2,rind_s)/tau_si.*(vs(rind_s)+Mr)/(M+Mr));
    
    is_spike = find(0.25*ex_e(step,rind_e)*s_exe < s_ee*he(1,rind_e)/tau_ee & ve(rind_e)>M);

    % exponential decay of input in each step
    he=he.*[exp(-dt/tau_ee);exp(-dt/tau_ei);exp(-dt/tau_es)];   
    hi=hi.*[exp(-dt/tau_ie);exp(-dt/tau_ii);exp(-dt/tau_is)];
    hs=hs.*[exp(-dt/tau_se);exp(-dt/tau_si)];
    
    % spike index
    % M: Spike threshold
    sind_e = ve > M; 
    sind_i = vi > M; 
    sind_s = vs > M;
    spikecount_e = sum(sind_e);
    spikecount_i = sum(sind_i);
    spikecount_s = sum(sind_s);

    % spike number in each msMr
    if flag==1
        wave_spike_count(wave_count) = wave_spike_count(wave_count) + spikecount_e + spikecount_i + spikecount_s; 
    end
    wave_record(wave_record(1)+2 : wave_record(1)+ length(is_spike)+1) = time;
    wave_record(1) = wave_record(1) + length(is_spike);
    
    if spikecount_e>0
        if tau_re < 0  % tau_re: refractory period
            ve(sind_e) = ve(sind_e) - M;    
        else
            ve(sind_e) = 0; % reset to zero
            refc_e(sind_e) = refc_e(sind_e) + tau_re;    % update reference clock
        end

        % update excitatory post-synaptic inputs
        he(1,:) = he(1,:) + sum(connection_matrix_e(sind_e, 1:ne)               ,1);    
        hi(1,:) = hi(1,:) + sum(connection_matrix_e(sind_e, ne+1:ne+ni)         ,1);
        hs(1,:) = hs(1,:) + sum(connection_matrix_e(sind_e, ne+ni+1:ne+ni+ns)   ,1);

        % write down the spike time
        spike_e(1,sind_e) = spike_e(1,sind_e) + 1;  % spike number + 1 for each firing neuron              
        spikeind = nearray(sind_e)*spike_row + spike_e(1,sind_e) + 1;
        spike_e(round(spikeind)) = step*dt;
    end

    if spikecount_i>0
         if tau_ri < 0
            vi(sind_i) = vi(sind_i) - M;
         else
            vi(sind_i) = 0;
            refc_i(sind_i) = refc_i(sind_i) + tau_ri;
         end
        
        % update inhibitory post-synaptic inputs
        he(2,:)=he(2,:) + sum(connection_matrix_i(sind_i,1:ne),             1);
        hi(2,:)=hi(2,:) + sum(connection_matrix_i(sind_i,ne+1:ne+ni),       1);
        hs(2,:)=hs(2,:) + sum(connection_matrix_i(sind_i,ne+ni+1:ne+ni+ns), 1);

        % write down the spike time
        spike_i(1,sind_i) = spike_i(1,sind_i)+1; 
        spikeind = niarray(sind_i)*spike_row + spike_i(1,sind_i)+1;
%         disp(round(spikeind)); % for debug
        spike_i(round(spikeind))= step*dt ;
    end

    % obtain the delayed som inhibition from buffer
    he(3,:) = he(3,:) + s2e_inhibition_buffer(1, :);
    hi(3,:) = hi(3,:) + s2i_inhibition_buffer(1, :);

    % update som_inhibition_buffer
    for buffer_i = 1 : (s2e_delay_steps-1)
        s2e_inhibition_buffer(buffer_i, :) = s2e_inhibition_buffer(buffer_i+1, :);
    end

    for buffer_i = 1 : (s2i_delay_steps-1)
        s2i_inhibition_buffer(buffer_i, :) = s2i_inhibition_buffer(buffer_i+1, :);
    end

    s2e_inhibition_buffer(s2e_delay_steps, :) = 0;
    s2i_inhibition_buffer(s2i_delay_steps, :) = 0;

    if spikecount_s>0
         if tau_rs < 0
            vs(sind_s) = vi(sind_s) - M;
         else
            vs(sind_s) = 0;
            refc_s(sind_s) = refc_s(sind_s) + tau_rs;
         end

        % store the som inhibition to buffer
        s2e_inhibition_buffer(s2e_delay_steps, :) = sum(connection_matrix_s(sind_s, 1:ne), 1);
        s2i_inhibition_buffer(s2i_delay_steps, :) = sum(connection_matrix_s(sind_s, ne+1 : ne+ni), 1);    

        % write down the spike time
        spike_s(1,sind_s) = spike_s(1,sind_s) + 1;      
        spikeind = nsarray(sind_s)*spike_row+spike_s(1,sind_s)+1;
        spike_s(round(spikeind)) = step*dt;
    end

    % eliminate overtime wave
    if wave_record(1)>0 && (time - wave_record(2) > delay)   
        num_pop = sum(time - wave_record(2 : wave_record(1)+1) > delay);   
        wave_record(2 : wave_record(1)+1-num_pop) = wave_record(num_pop+2 : wave_record(1)+1);  % eliminate overtime wave
        wave_record(1) = wave_record(1) - num_pop; 
    end

    % start new wave
    if flag==0 && wave_record(1)> start_threshold && time - flag_time >= flag_off_time
        flag = 1;
        flag_time = time;
        res.MFE_time(wave_count,1) = time;
        res.HEE_stat(wave_count,1) = sum(he(1,:));
        HEE_max = sum(he(1,:));
    end

    % update max excitatory inputs
    if flag ==1 && HEE_max < sum(he(1,:))
        HEE_max =sum(he(1,:));
    end

    % end new wave
%     if flag ==1 && (wave_record(1)<= end_threshold || (time > flag_time+10 && sum(he(1,:))<50))
    if flag ==1 && (wave_record(1)<= end_threshold || time > flag_time+10 )
        flag = 0;
        flag_time = time;
        res.MFE_time(wave_count, 2) = time;
        res.HEE_stat(wave_count, 2) = HEE_max;
        res.HEE_stat(wave_count, 3) = sum(he(1,:));
        HEE_max = 0;
        wave_count = wave_count +1;
    end
    
    % update output
    res.VE(step,:)=ve(:);
    res.VI(step,:)=vi(:);
    res.VS(step,:)=vs(:);
    res.HE(step,:)=[he(1,:),hi(1,:),hs(1,:)];
    res.HI(step,:)=[he(2,:),hi(2,:),hs(2,:)];
    res.HS(step,:)=[he(3,:),hi(3,:)];
    res.spikecount_e(step) = spikecount_e;
    res.spikecount_i(step) = spikecount_i;
    res.spikecount_s(step) = spikecount_s;
end

res.spike = [spike_e, spike_i, spike_s];
res.spike(2:end,:) = res.spike(2:end,:)/1000;    % s

index2 = 1;
index = 1;
while index < wave_count
    MFE_time2(index2,1) = res.MFE_time(index,1);
    HEE_stat2(index2,1) = res.HEE_stat(index,1);
    local_sp_count = 0;
    local_HEE_max = res.HEE_stat(index,2);
    while true
        local_sp_count = local_sp_count + wave_spike_count(index);
        if local_HEE_max < res.HEE_stat(index,2)
            local_HEE_max = res.HEE_stat(index,2);
        end
        HEE_stat2(index2, 3) = res.HEE_stat(index,3);
        MFE_time2(index2, 2) = res.MFE_time(index,2);
        index = index+1;
        if (res.MFE_time(index,1) - res.MFE_time(index-1,2)>= MFE_interval)|| index>wave_count
            break;
        end
    end
    wave_spike_count2(index2) = local_sp_count;
    HEE_stat2(index2,2) = local_HEE_max;
    index2  = index2 +1;
end

wave_count              = index2;
res.MFE_time            = MFE_time2;
res.HEE_stat            = HEE_stat2;
wave_spike_count        = wave_spike_count2;
res.wave_spike_count    = wave_spike_count;
res.wave_count          = wave_count;

end