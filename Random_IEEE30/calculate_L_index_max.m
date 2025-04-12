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