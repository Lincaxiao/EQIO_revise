function bus_voltage = Get_Voltage(case_name)
%% 得到case_name在Test_name中的位置
case_name = string(case_name);

Test_name = ["x30_Cost_Base", "x30_Cost_with_Tax", "x30_Cost_with_VPLE", "x30_Ploss", ...
    "x30_Voltage_Deviation", "x30_Cost_Ploss", "x30_Cost_VD", "x30_Cost_Tax_Ploss_VD", "x30_L_index"];
case_name_index = find(ismember(Test_name, case_name));
i = case_name_index;
Method_name = ["TLBO", "PSO", "PLO", "SMA", "HGS", "MGO", "APO", "EAPO"];

load('IEEE30_non_random_Result.mat');
Result = IEEE30_non_random_Result;
%% 获取各个case各个算法的最优解得到系统各节点的电压
for j = 1:length(Method_name)
    x = Result.(Test_name{i}).(Method_name{j}).Best_solution;
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
    V = res.bus(:, 8);
    bus_voltage(j, :) = V;
    %% 如果有大于1.06或小于0.94的电压，返回0
    if sum(V > 1.06) > 0 || sum(V < 0.94) > 0
        %% 打印算法名字 + 位置
        %error('Voltage is out of range!');
        disp(Method_name(j) + " " + case_name + "loaction" + find(V > 1.06 | V < 0.94));
    end
end
end