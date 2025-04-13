clc;
clear;
close all;
%% 注意Best_solution中Slack节点的x需要被替换
if exist('IEEE118_non_random_multi_Result.mat', 'file')
    load('IEEE118_non_random_multi_Result.mat');
    Result = IEEE118_non_random_multi_Result;
end


Test_name = ["118_Cost_Base", "118_Ploss", "118_Voltage_Deviation",...
            "118_Cost_Ploss", "118_Cost_VD", "118_Cost_Ploss_VD"];
% Method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Method_name = ["PSO", "TSO", "PO", "IVY", "DOA", "TLBO", "QIO", "EQIO"];
Pop_number = 20;
Max_Iteration = 150;

% 将 Test_name 和 Method_name 转换为有效的字段名称
% * 需要运行30次
Test_name_fields = matlab.lang.makeValidName(Test_name);
Method_name_fields = matlab.lang.makeValidName(Method_name);
tic;
for i=1:length(Test_name)
    [lb, ub, dim, fobj] = Get_function_details(Test_name(i));
    [lb, ub, dim, fobj_non_penalty] = Get_function_details_without_penalty(Test_name(i));
    for j=4:5%1:length(Method_name)
        if j ~= 8
            Pop_number = 20;
        else
            Pop_number = 30;
        end
        Fitness_array = zeros(1, 30);
        Solution_array = zeros(30, 129);
        Cost_array = zeros(1, 30);
        Ploss_array = zeros(1, 30);
        VD_array = zeros(1, 30);
        L_index_array = zeros(1, 30);
        Iteration_Curve_array = zeros(30, Max_Iteration);
        parfor k=1:30
            [Best_fitness, Best_solution, Iteration_Curve] = feval(Method_name{j}, fobj, lb, ub, dim, Pop_number, Max_Iteration);
            [x_30, Cost, Ploss, VD, L_index] = IEEE118_Cal_all(Best_solution);
            Best_solution(30) = x_30;
            Best_fitness = fobj_non_penalty(Best_solution);
            Fitness_array(k) = Best_fitness;
            Solution_array(k, :) = Best_solution;
            Cost_array(k) = Cost;
            Ploss_array(k) = Ploss;
            VD_array(k) = VD;
            L_index_array(k) = L_index;
            Iteration_Curve_array(k, :) = Iteration_Curve;
        end
        % * 找到最好结果的索引
        [Best_fitness, Best_index] = min(Fitness_array);
        Best_solution = Solution_array(Best_index, :);
        Cost = Cost_array(Best_index);
        Ploss = Ploss_array(Best_index);
        VD = VD_array(Best_index);
        L_index = L_index_array(Best_index);
        Mean = mean(Fitness_array);
        Std = std(Fitness_array);
        Worst_fitness = max(Fitness_array);
        Result.(Test_name_fields{i}).(Method_name_fields{j}) = struct(...
            'Fitness_array', Fitness_array, ...
            'Best_fitness', Best_fitness, ...
            'Solution_array', Solution_array, ...
            'Best_solution', Best_solution, ...
            'Best_Iteration_Curve', Iteration_Curve_array(Best_index, :), ...
            'Cost', Cost, ...
            'Ploss', Ploss, ...
            'VD', VD, ...
            'L_index', L_index, ...
            'Mean', Mean, ...
            'Std', Std, ...
            'Worst_fitness', Worst_fitness);
    end
end
toc;
disp(['Time cost: ', num2str(toc), 's']);
% 保存结果
IEEE118_non_random_multi_Result = Result;
save('IEEE118_non_random_multi_Result.mat', 'IEEE118_non_random_multi_Result');