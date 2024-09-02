% % Filename: rasterplot (Version-2)
% % Date: 2024.8.19
% % Author: Jiatong Guo
% % Description: A function to show scatterplots and save them in folder output

function [] = rasterplot2(res, param)

ne = param.ne;
ni = param.ni;
ns = param.ns;

spike = res.spike;

num_E   = sum(spike(1,1:ne));
num_I   = sum(spike(1,ne+1:ne+ni));
num_S   = sum(spike(1,ne+ni+1:ne+ni+ns));
coor_E  = zeros(num_E,2);
coor_I  = zeros(num_I,2);
coor_S  = zeros(num_S,2);
index_E = 1;
index_I = 1;
index_S = 1;

ave_E   = num_E / ne / param.duration * 1000;
ave_I   = num_I / ni / param.duration * 1000;
ave_S   = num_S / ns / param.duration * 1000;

% display(ave_E);
% display(ave_I);
% display(ave_S);

for i=1:ne
    num_Ei = spike(1,i);
    coor_E(index_E:index_E+num_Ei-1,1) = i;
    coor_E(index_E:index_E+num_Ei-1,2) = spike(2:1+num_Ei,i)*1000;
    index_E = index_E + num_Ei;
end

for i=(ne+1):(ne+ni)
    num_Ii = spike(1,i);
    coor_I(index_I:index_I+num_Ii-1,1) = i;
    coor_I(index_I:index_I+num_Ii-1,2) = spike(2:1+num_Ii,i)*1000;
    index_I = index_I + num_Ii;
end

for i=(ne+ni+1):(ne+ni+ns)
    num_Si = spike(1,i);
    coor_S(index_S:index_S+num_Si-1, 1) = i;
    coor_S(index_S:index_S+num_Si-1, 2) = spike(2:1+num_Si,i)*1000;
    index_S = index_S + num_Si;
end


scatter(coor_E(:,2), coor_E(:,1),10,'.','r');
hold on
scatter(coor_I(:,2), coor_I(:,1),10,'.','b');
hold on 
scatter(coor_S(:,2), coor_S(:,1),10,'.','g');

% title('E-cells:red, PVs:bule, SOMs:green')
title(sprintf('S_{es} = %.4f, S_{is} = %.4f, \\tau_{es}^{delay} = %d ms, \\tau_{is}^{delay} = %d ms', param.s_es / 100, param.s_is / 100, param.s2e_delay, param.s2i_delay), 'FontSize', 25);
% title(sprintf('s2e\\_delay = %d ms, s2i\\_delay = %d ms', param.s2e_delay, param.s2i_delay), 'FontSize', 25);
xlabel('time(ms)');
ylabel('Neuron Index');
set(gca,'fontsize',20);
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);


% text(700, 100, sprintf('SOM Firing Rate: %.2f Hz', ave_S), 'FontSize', 25, 'Color', 'green');
% text(700, 60, sprintf('PVs Firing Rate: %.2f Hz', ave_I), 'FontSize', 25, 'Color', 'blue');
% text(700, 20, sprintf('PCs Firing Rate: %.2f Hz', ave_E), 'FontSize', 25, 'Color', 'red');

% 获取当前轴的位置（在figure中的位置，以normalized单位）
ax = gca; % Get current axes
ax_pos = ax.Position;

% 计算文本框的相对位置（右下角）
x_pos = ax_pos(1) + ax_pos(3) - 0.25; % 右边缘距离 - 文本框宽度
y_pos1 = ax_pos(2) + 0.05; % 底边缘距离
y_pos2 = y_pos1 + 0.05;    % 第二个文本框
y_pos3 = y_pos2 + 0.05;    % 第三个文本框

% SOM Firing Rate
annotation('textbox', [x_pos, y_pos3, 0.2, 0.05], 'String', sprintf('SOM: %.2f Hz', ave_S), ...
    'FontSize', 25, 'Color', 'green', 'EdgeColor', 'none', 'HorizontalAlignment', 'right');

% PVs Firing Rate
annotation('textbox', [x_pos, y_pos2, 0.2, 0.05], 'String', sprintf('PVs: %.2f Hz', ave_I), ...
    'FontSize', 25, 'Color', 'blue', 'EdgeColor', 'none', 'HorizontalAlignment', 'right');

% PCs Firing Rate
annotation('textbox', [x_pos, y_pos1, 0.2, 0.05], 'String', sprintf('PCs: %.2f Hz', ave_E), ...
    'FontSize', 25, 'Color', 'red', 'EdgeColor', 'none', 'HorizontalAlignment', 'right');

