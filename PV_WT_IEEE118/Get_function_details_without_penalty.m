function [lb, ub, dim, fobj] = Get_function_details_without_penalty(function_name)
    dim = 129;
    ub = [100, 100, 100, 100, 550, 185, 100, 100, 100, 100, ...
        320, 414, 100, 107, 100, 100, 100, 100, 100, 119, ...
        304, 148, 100, 100, 255, 260, 100, 491, 492, 805.2, ...
        100, 100, 100, 100, 100, 100, 577, 100, 104, 707, ...
        100, 100, 100, 100, 352, 140, 100, 100, 100, 100, ...
        136, 100, 100, 100, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 30,  30,  30 , ...
        30,  30,  30,  30,  30,  30,  30,  30,  30];
    lb = [0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.90,0.90, ...
        0.90,0.90,0.90,0.90,0.90,0.90,0.90,0,   0,   0,   ...
        0,   0,   0,   0,   0,   0,   0,   0,   0];
    fobj = @(x) Fun_case118(x, function_name);
end

function y = Fun_case118(x, function_name)
    % 1-54: P  55-108: V 109-117: T 118-129: Q
    xMax = [100, 100, 100, 100, 550, 185, 100, 100, 100, 100, ...
        320, 414, 100, 107, 100, 100, 100, 100, 100, 119, ...
        304, 148, 100, 100, 255, 260, 100, 491, 492, 805.2, ...
        100, 100, 100, 100, 100, 100, 577, 100, 104, 707, ...
        100, 100, 100, 100, 352, 140, 100, 100, 100, 100, ...
        136, 100, 100, 100, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, ...
        1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 30,  30,  30 , ...
        30,  30,  30,  30,  30,  30,  30,  30,  30];
    xMin = [0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, ...
        0,   0,   0,   0,   0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95, ...
        0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.90,0.90, ...
        0.90,0.90,0.90,0.90,0.90,0.90,0.90,0,   0,   0,   ...
        0,   0,   0,   0,   0,   0,   0,   0,   0];
        data = case118;
        data.gen(:, 2) = x(1:54); % 发电机有功功率
        data.gen(:, 6) = x(55:108); % 发电机电压幅值
        data.branch(8, 9) = x(109); % 变压器分接头位置
        data.branch(32, 9) = x(110);
        data.branch(36, 9) = x(111);
        data.branch(61, 9) = x(112);
        data.branch(93, 9) = x(113);
        data.branch(95, 9) = x(114);
        data.branch(102, 9) = x(115);
        data.branch(107, 9) = x(116);
        data.branch(127, 9) = x(117);
        data.bus(34, 6) = x(118); % 并联电容无功补偿
        data.bus(44, 6) = x(119);
        data.bus(45, 6) = x(120);
        data.bus(46, 6) = x(121);
        data.bus(48, 6) = x(122);
        data.bus(74, 6) = x(123);
        data.bus(79, 6) = x(124);
        data.bus(82, 6) = x(125);
        data.bus(83, 6) = x(126);
        data.bus(105, 6) = x(127);
        data.bus(107, 6) = x(128);
        data.bus(110, 6) = x(129);
        opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0);
        res = runpf(data, opt);
        Ploss = sum(res.branch(:, 14) + res.branch(:, 16)); % 网损
        Cost = 0;
        for i = 1:54
            if i == 3 || i == 7 || i == 16 || i == 8 || i == 23 || i == 47
                continue;
            end
            P = res.gen(i, 2);
            Cost = Cost + res.gencost(i, 5) * P^2 + res.gencost(i, 6) * P;
        end
        Cost = Cost + Cal_PV_WT_Cost(x(3), 2, 1) + Cal_PV_WT_Cost(x(7), 2, 2) + ...
            Cal_PV_WT_Cost(x(16), 2, 3) + Cal_PV_WT_Cost(x(8), 1, 1) + ...
            Cal_PV_WT_Cost(x(23), 1, 2) + Cal_PV_WT_Cost(x(47), 1, 3);
        penalty = 0;
        for i = 1:129
            if x(i) > xMax(i) 
                penalty = penalty + (x(i) - xMax(i))^2 * 50 + 5;
            end
            if x(i) < xMin(i)
                penalty = penalty + (xMin(i) - x(i))^2 * 50 + 5;
            end
        end
        Vmax = 1.06;
        Vmin = 0.94;
        V = res.bus(:, 8);
        for i = 1:118
            if V(i) > Vmax
                penalty = penalty + (V(i) - Vmax) * 100 + 5000;
            end
            if V(i) < Vmin
                penalty = penalty + (Vmin - V(i)) * 100 + 5000;
            end
        end
        VD = sum(abs(V - 1));
        switch function_name
            case "118_Cost_Base"
                y = Cost;
            case "118_Ploss"
                y = Ploss;
            case "118_Voltage_Deviation"
                y = VD;
            case "118_Cost_Ploss"
                y = Cost + 1500 * Ploss;
            case "118_Cost_VD"
                y = Cost + 10000 * VD;
            case "118_Cost_Ploss_VD"
                y = Cost + 750 * Ploss + 5000 * VD;
            case "118_L_index"
                y = calculate_L_index_max(res);
        end
        if res.success == 0
            y = 1e10;
        end
end

function [Cost] = Cal_PV_WT_Cost(expected_power, Type, PV_or_WT_index)
    if Type == 1
        Cost = Cal_WT(expected_power, PV_or_WT_index);
    else
        Cost = Cal_PV(expected_power, PV_or_WT_index);
    end
end

function [y] = Cal_WT(expected_power, index)
    lower_coefficient = [1.5, 1.5, 1.5];
    upper_coefficient = [3, 3, 3];
    direct_coefficient = [1.75, 1.75, 1.75];
    power_times_coefficient = [100/3, 100/3, 100/3]; %% * 对应100MW的风机
    lower_cost = lower_coefficient(index);
    upper_cost = upper_coefficient(index);
    direct_cost = direct_coefficient(index);
    power_times = power_times_coefficient(index);
    expected_power = expected_power / power_times;
    % 计算power=3MW的概率
    prob_for_3MW = integral(@(v) Cal_WT_probability_for_v(v, index), 16, 25);
    % 计算出功率对应的风速，假定power不会超过3MW，也不会低于0
    reflected_v = expected_power / 3 * 13 + 3;
    Reserved_cost = power_times * upper_cost * integral(@(v) (expected_power - Cal_P(v)) .* Cal_WT_probability_for_v(v, index), 0, reflected_v);
    Penalty_cost = power_times * lower_cost * (integral(@(v) (Cal_P(v) - expected_power) .* Cal_WT_probability_for_v(v, index), reflected_v, 16) + prob_for_3MW * (3 - expected_power));
    Direct_cost = power_times * direct_cost * expected_power;
    y = Reserved_cost + Penalty_cost + Direct_cost;
end

function [power] = Cal_P(v)
    power = 3 * (v - 3) / 13;
end

function [probability_for_v] = Cal_WT_probability_for_v(v, index)
    fi_for_wind = [2, 2, 2];
    ksi_for_wind = [9, 9, 9];
    fi = fi_for_wind(index);
    ksi = ksi_for_wind(index);
    probability_for_v = (fi/ksi)*((v/ksi).^(fi-1)).*exp(-((v/ksi).^fi));
end

function [y] = Cal_PV(expected_power, index)
    lower_coefficient = [1.5, 1.5, 1.5];
    upper_coefficient = [3, 3, 3];
    direct_coefficient = [1.6, 1.6, 1.6];
    [larger_power, larger_probability] = Cal_PV_probability_for_power(expected_power, index, 1);
    [smaller_power, smaller_probability] = Cal_PV_probability_for_power(expected_power, index, 2);
    Reserved_cost = upper_coefficient(index) * smaller_probability * (expected_power - smaller_power); 
    Penalty_cost = lower_coefficient(index) * larger_probability * (larger_power - expected_power);
    Direct_cost = direct_coefficient(index) * expected_power;
    y = Reserved_cost + Penalty_cost + Direct_cost;
end

function [prob] = LognormalPDF(x)
    lambda = 0.6;
    fi = 6;
    prob = 1 ./ (x .* sqrt(2 * pi) * lambda) .* exp(-((log(x) - fi).^2) ./ (2 * lambda^2));
end

%% 计算大于或者小于给定功率的概率和期望
function [expected_power, probability] = Cal_PV_probability_for_power(power, index, Type_of_large_or_small)
    % Type = 1 代表大于，Type = 2 代表小于
    % 计算出功率对应的光照强度
    if power < 100*120/800
        x = sqrt(power*800*120 / 100);
    else
        x = power * 800 / 100;
    end
    %% 计算avaible power大于或者小于给定功率的概率
    small_probability = integral(@(g) LognormalPDF(g), 0.01, x);
    large_probability = integral(@(g) LognormalPDF(g), x, 2500);
    if Type_of_large_or_small == 1
        expected_power = integral(@(g) g .* LognormalPDF(g), x, 2500) / large_probability /800 * 100;
        probability = large_probability;
    else
        expected_power = integral(@(g) g .* LognormalPDF(g), 0.01, x) / small_probability /800 * 100;
        probability = small_probability;
    end
end

%% 计算电压稳定性指标 L-index
function L_max = calculate_L_index_max(results)
    mpc = results;
    % 获取导纳矩阵 (Ybus)
    [Ybus, ~, ~] = makeYbus(mpc.baseMVA, mpc.bus, mpc.branch);
    
    % PQ节点 (负载节点) 和 PV节点 (发电机节点)
    PQ = find(mpc.bus(:, 2) == 1);  % PQ 节点索引
    PV = find(mpc.bus(:, 2) == 2 | mpc.bus(:, 2) == 3);  % PV 节点索引
    NL = length(PQ);  % PQ 节点数量
    NG = length(PV);  % PV 节点数量
    
    % 计算子矩阵 Y_LL 和 Y_LG
    Y_LL = Ybus(PQ, PQ);  % PQ节点的导纳子矩阵
    Y_LG = Ybus(PQ, PV);  % PQ节点和PV节点之间的导纳子矩阵
    
    % 获取节点电压结果（幅值和相角）
    V = results.bus(:, 8);  % 节点电压幅值
    theta = results.bus(:, 9) * pi / 180;  % 节点电压相角，转换为弧度
    
    V_L = V(PQ);  % PQ节点电压幅值
    V_G = V(PV);  % PV节点电压幅值
    theta_L = theta(PQ);  % PQ节点电压相角
    theta_G = theta(PV);  % PV节点电压相角
    
    % 计算 F_ji = - inv(Y_LL) * Y_LG
    F = -inv(Y_LL) * Y_LG;
    
    % 初始化L-index结果
    L_index = zeros(NL, 1);
    
    % 计算L-index，包含电压幅值和相角
    for j = 1:NL
        sum_FV_ratio = 0;
        for i = 1:NG
            % 获取 Fji 的相角和幅值
            theta_ji = angle(F(j, i));  % Fji 的相角
            F_magnitude = abs(F(j, i));  % Fji 的幅值
            delta_theta = theta_G(i) - theta_L(j);  % (delta_i - delta_j)
            
            % 计算Vi / Vj
            voltage_ratio = V_G(i) / V_L(j);
            
            % 累加 Fji * (Vi / Vj) * exp(j * (theta_ji + delta_i - delta_j))
            sum_FV_ratio = sum_FV_ratio + F_magnitude * voltage_ratio * exp(1i * (theta_ji + delta_theta));
        end
        
        % L_j 计算公式: L_j = |1 - Σ Fji * (Vi/Vj) * exp(j(θ_ji + δ_i - δ_j))|
        L_index(j) = abs(1 - sum_FV_ratio);
    end
    % 最大L-index作为目标函数
    L_max = max(L_index);
end
