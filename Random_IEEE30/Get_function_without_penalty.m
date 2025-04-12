function [lb, ub, dim, fobj] = Get_function_without_penalty(function_name, Grid_Index)
    dim = 25;
    ub = [1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10...
                    5,    5,  5,  5,  5,  5, 5,  5,  5, 200, 80, 75, 35, 60, 50];
    lb = [0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.90, 0.90, 0.90, 0.90...
        0,    0,    0,    0,    0,    0,    0,    0,    0, 50, 20, 15, 10, 10, 12];
    switch function_name
        case {'30_Cost_Base', '30_Cost_with_Tax', '30_Ploss', '30_Voltage_Deviation', '30_Cost_Ploss', ...
                '30_Cost_VD', '30_Cost_Tax_Ploss_VD', '30_L_index'}
            fobj = @(x) Fun_ieee30_without_VPLE(x, function_name, Grid_Index);
        case '30_Cost_with_VPLE'
            fobj = @(x) Fun_ieee30_with_VPLE(x, Grid_Index);
    end
end

function y = Fun_ieee30_without_VPLE(x, function_name, Grid_Index)
    %% 包括 Cost_Base, Cost_with_Tax, PLoss, Voltage_Deviation, Cost_Ploss, Cost_VD, Cost_Tax_Ploss_VD
    %       V1,   V2,   V5,   V8,   V11,  V13   T11   T12   T15   T36  
    %       Q10   Q12   Q15   Q17   Q20   Q21   Q23   Q24   Q29
    xMax = [1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10...
                    5,    5,  5,  5,  5,  5, 5,  5,  5, 200, 80, 75, 35, 60, 50];
    xMin = [0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.90, 0.90, 0.90, 0.90...
        0,    0,    0,    0,    0,    0,    0,    0,    0, 50, 20, 15, 10, 10, 12];

    load('Gen_IEEE30_Array.mat'); %% 现在工作区中有一个名为 Gen_IEEE30_Array 的结构数组
    data = Gen_IEEE30_Array(Grid_Index);
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
    Ploss = sum(res.branch(:, 14) + res.branch(:, 16)); % 网损
    Cost = 0;
    res.gencost = [
        2	0	0	3	0.00375	2	0;
        2	0	0	3	0.0175	1.75	0;
        2	0	0	3	0	0	0; % WT1
        2	0	0	3	0.00834	3.25	0;
        2	0	0	3	0	0	0; % WT2
        2	0	0	3	0	0	0; % PV
    ];
    for i = 1:6
        P = res.gen(i, 2);
        Cost = Cost + res.gencost(i, 5) * P^2 + res.gencost(i, 6) * P;
    end
    Cost = Cost + Cal_PV_WT_Cost(x(22), 1, 1) + Cal_PV_WT_Cost(x(24), 1, 2) + Cal_PV_WT_Cost(x(25), 2, 1);
    penalty = 0;
    for i = 1:25
        if x(i) > xMax(i) 
            penalty = penalty + (x(i) - xMax(i)) * 50 + 50;
        end
        if x(i) < xMin(i)
            penalty = penalty + (xMin(i) - x(i)) * 50 + 50;
        end
    end
    Vmax = 1.06;
    Vmin = 0.94;
    V = res.bus(:, 8);
    for i = 1:30
        if V(i) > Vmax
            penalty = penalty + (V(i) - Vmax) * 100;
        end
        if V(i) < Vmin
            penalty = penalty + (Vmin - V(i)) * 100;
        end
    end
    VD = sum(abs(V - 1));

    switch function_name
        case '30_Cost_Base'
            y = Cost;
        case '30_Cost_with_Tax'
            y = Cost + Cal_Tax(x);
        case '30_Ploss'
            y = Ploss;
        case '30_Voltage_Deviation'
            y = VD ;
        case '30_Cost_Ploss'
            y = Cost + 40 * Ploss;
        case '30_Cost_VD'
            y = Cost + 100 * VD ;
        case '30_Cost_Tax_Ploss_VD'
            y = Cost + Cal_Tax(x) + 21 * Ploss + 22 * VD ;
        case '30_L_index'
            y = calculate_L_index_max(res);
    end
end

function y = Fun_ieee30_with_VPLE(x, Grid_Index)
    %% 30_Cost_with_VPLE
    %       V1,   V2,   V5,   V8,   V11,  V13   T11   T12   T15   T36  
    %       Q10   Q12   Q15   Q17   Q20   Q21   Q23   Q24   Q29
    xMax = [1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10, 1.10...
                    5,    5,  5,  5,  5,  5, 5,  5,  5, 200, 80, 75, 35, 60, 50];
    xMin = [0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.90, 0.90, 0.90, 0.90...
        0,    0,    0,    0,    0,    0,    0,    0,    0, 50, 20, 15, 10, 10, 12];
    
    load('Gen_IEEE30_Array.mat'); %% 现在工作区中有一个名为 Gen_IEEE30_Array 的结构数组
    data = Gen_IEEE30_Array(Grid_Index);
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
    %% 阀点效应
    Valve_Point_Coefficient = [
        18 0.037;
        16 0.038;
        0  0;
        12 0.045;
        0  0;
        0  0;
    ];
    Cost = 0;
    for i = 1:6
        P = res.gen(i, 2);
        Cost = Cost + res.gencost(i, 5) * P^2 + res.gencost(i, 6) * P + Valve_Point_Coefficient(i, 1) * abs(P * Valve_Point_Coefficient(i, 2));
    end
    Cost = Cost + Cal_PV_WT_Cost(x(22), 1, 1) + Cal_PV_WT_Cost(x(24), 1, 2) + Cal_PV_WT_Cost(x(25), 2, 1);
    penalty = 0;
    for i = 1:25
        if x(i) > xMax(i) 
            penalty = penalty + (x(i) - xMax(i)) * 50 + 50;
        end
        if x(i) < xMin(i)
            penalty = penalty + (xMin(i) - x(i)) * 50 + 50;
        end
    end
    Vmax = 1.06;
    Vmin = 0.94;
    V = res.bus(:, 8);
    for i = 1:30
        if V(i) > Vmax
            penalty = penalty + (V(i) - Vmax) * 100;
        end
        if V(i) < Vmin
            penalty = penalty + (Vmin - V(i)) * 100;
        end
    end
    y = Cost ;
end

function y = Cal_Tax(x)
    Tax_coefficient = [
        0.04091 -0.05554 0.0649  0.0002 6.667;
        0.02543 -0.06047 0.05638 0.0005 3.333;
        0        0       0       0      0;
        0.05326 -0.0355  0.0338  0.002  2;
    ];
    %% 计算标幺值 100MVA / 1.0 p.u.
    gen_1 = x(20) / 100;
    gen_2 = x(21) / 100;
    gen_4 = x(23) / 100;

    gen_1_Tax = 20 * (Tax_coefficient(1, 1) + Tax_coefficient(1, 2) * gen_1 + Tax_coefficient(1, 3) * gen_1^2 ...
        + Tax_coefficient(1, 4) * exp(Tax_coefficient(1, 5) * gen_1));
    gen_2_Tax = 20 * (Tax_coefficient(2, 1) + Tax_coefficient(2, 2) * gen_2 + Tax_coefficient(2, 3) * gen_2^2 ...
        + Tax_coefficient(2, 4) * exp(Tax_coefficient(2, 5) * gen_2));
    gen_4_Tax = 20 * (Tax_coefficient(4, 1) + Tax_coefficient(4, 2) * gen_4 + Tax_coefficient(4, 3) * gen_4^2 ...
        + Tax_coefficient(4, 4) * exp(Tax_coefficient(4, 5) * gen_4));
    y = gen_1_Tax + gen_2_Tax + gen_4_Tax;
end
