function [x_20, Emission, Ploss, VD, L_index] = IEEE30_Cal_all(Best_sol)
% Calculate the emission, power loss and voltage deviation of IEEE30 system
x = Best_sol;
data = case_ieee30;
data.gen(:, 6) = x(1 : 6); % 发电机电压幅值
data.branch(11, 9) = x(7); % 变压器分接头位置
data.branch(12, 9) = x(8); 
data.branch(15, 9) = x(9); 
data.branch(36, 9) = x(10);
% 并联电容无功补偿
data.bus(10, 6) = x(11);
data.bus(12, 6) = x(12);
data.bus(15, 6) = x(13);
data.bus(17, 6) = x(14);
data.bus(20, 6) = x(15);
data.bus(21, 6) = x(16);
data.bus(23, 6) = x(17);
data.bus(24, 6) = x(18);
data.bus(29, 6) = x(19);
data.gen(2:6, 2) = x(21:25); % 发电机有功功率
opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0);
res = runpf(data, opt);
x(20) = res.gen(1, 2); % PV1
res.gencost = [
    2	0	0	3	0.00375	2	0;
    2	0	0	3	0.0175	1.75	0;
    2	0	0	3	0	0	0; % WT1
    2	0	0	3	0.00834	3.25	0;
    2	0	0	3	0	0	0; % WT2
    2	0	0	3	0	0	0; % PV
];

Ploss = sum(res.branch(:, 14) + res.branch(:, 16)); % 网损
Emission = Cal_Tax_All(x) / 20;
VD = sum(abs(res.bus(:, 8) - 1));
x_20 = x(20);
L_index = calculate_L_index_max(res);
end
