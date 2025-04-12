function [Cost] = Cal_PV_WT_Cost(expected_power, Type, PV_or_WT_index)
    if Type == 1
        Cost = Cal_WT(expected_power, PV_or_WT_index);
    else
        Cost = Cal_PV(expected_power, PV_or_WT_index);
    end
end

function [y] = Cal_WT(expected_power, index)
    lower_coefficient = [1.5, 1.5];
    upper_coefficient = [3, 3];
    direct_coefficient = [1.6, 1.75];
    power_times_coefficient = [25, 20];
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
    fi_for_wind = [2, 2];
    ksi_for_wind = [9, 10];
    fi = fi_for_wind(index);
    ksi = ksi_for_wind(index);
    probability_for_v = (fi/ksi)*((v/ksi).^(fi-1)).*exp(-((v/ksi).^fi));
end

function [y] = Cal_PV(expected_power, index)
    lower_coefficient = [1.5];
    upper_coefficient = [3];
    direct_coefficient = [1.6];
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
    if power < 50*120/800
        x = sqrt(power*800*120 / 50);
    else
        x = power * 800 / 50;
    end
    %% 计算avaible power大于或者小于给定功率的概率
    small_probability = integral(@(g) LognormalPDF(g), 0.01, x);
    large_probability = integral(@(g) LognormalPDF(g), x, 2500);
    if Type_of_large_or_small == 1
        expected_power = integral(@(g) g .* LognormalPDF(g), x, 2500) / large_probability /800 * 50;
        probability = large_probability;
    else
        expected_power = integral(@(g) g .* LognormalPDF(g), 0.01, x) / small_probability /800 * 50;
        probability = small_probability;
    end
end
