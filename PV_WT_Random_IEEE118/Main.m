clc;
clear;
if exist('IEEE118_topo_Result.mat', 'file')
    load('IEEE118_topo_Result.mat');
    Result = IEEE118_topo_Result;
end
% 基础的费用测试同样包括了风电的参与
Test_name = ["118_Cost_Base", "118_Ploss", "118_Voltage_Deviation", ...
            "118_Cost_Ploss", "118_Cost_VD", "118_Cost_Ploss_VD"];
% Method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Method_name = ["PSO", "TSO", "PO", "IVY", "DOA", "TLBO", "QIO", "EQIO"];

% 将 Test_name 和 Method_name 转换为有效的字段名称
Test_name_fields = matlab.lang.makeValidName(Test_name);
Method_name_fields = matlab.lang.makeValidName(Method_name);

tic;
for i=1:length(Test_name)
    Praticle_size = 20;
    Max_Iteration = 100;
    All_Fitness = zeros(100, 8); %% 100张数据，8种算法
    Success_or_not = zeros(100, 8);
    for Algorithm_Index = 1:8
        % if Algorithm_Index ~= 8
        %     Praticle_size = 20;
        % else
        %     Praticle_size = 30;
        % end
        if Algorithm_Index ~= 4 && Algorithm_Index ~= 5
            All_Fitness(:, Algorithm_Index) = Result.(Test_name_fields(i)).All_Fitness(:, Algorithm_Index);
            continue;
        end
        Algorithm_name = Method_name(Algorithm_Index);
        %% 创建一个数组以容纳100张IEEE118数据的结果
        IEEE118_Result = zeros(100, 129); % 100张数据，每张数据129个参数
        IEEE118_Fitness = zeros(100, 1);
        parfor Grid_Index = 1:100
            [lb, ub, dim, fobj] = Get_function_details(Test_name(i), Grid_Index);
            [~, best_position, ~] = feval(Algorithm_name, fobj, lb, ub, dim, Praticle_size, Max_Iteration);
            %% 现在best_p中存储的是最优解
            IEEE118_Result(Grid_Index, :) = best_position;
            [a, b, c, func] = Get_function_without_penalty(Test_name(i), Grid_Index);
            %% 储存对应的适应度值
            [success, IEEE118_Fitness(Grid_Index)] = func(IEEE118_Result(Grid_Index, :));
            All_Fitness(Grid_Index, Algorithm_Index) = IEEE118_Fitness(Grid_Index);
        end
        %% 现在将适应度值储存在结构体中
        Tmp_array = struct('best_particle', IEEE118_Result, 'best_fit', IEEE118_Fitness);
        % 使用 genvarname 函数将其转换为有效的标识符
        valid_func_name = genvarname(Test_name(i));
        valid_Algorithm_name = genvarname(Algorithm_name);
        
        % 动态引用结构体字段
        Result.(valid_func_name).(valid_Algorithm_name) = Tmp_array;
    end
    %% 现在比较各个算法算出的对每一张数据的适应度值，并排名，存入各个算法的结构体中
    Rank_Array = zeros(size(All_Fitness));
    % 对每一行进行排序
    for j = 1:100
        % 计算每一行的排名
        Rank_Array(j, :) = tiedrank(All_Fitness(j, :));
    end
    %% 计算平均排名
    Average_Rank = mean(Rank_Array, 1); %% 按列求平均，Average_Rank是一个1*8的数组
    %% 对各个算法的结果进行Wilcoxon秩和检验
    Rank_Sum(1) = ranksum((All_Fitness(:, 8)), All_Fitness(:, 1));
    Rank_Sum(2) = ranksum((All_Fitness(:, 8)), All_Fitness(:, 2));
    Rank_Sum(3) = ranksum((All_Fitness(:, 8)), All_Fitness(:, 3));
    Rank_Sum(4) = ranksum((All_Fitness(:, 8)), All_Fitness(:, 4));
    Rank_Sum(5) = ranksum((All_Fitness(:, 8)), All_Fitness(:, 5));
    Rank_Sum(6) = ranksum((All_Fitness(:, 8)), All_Fitness(:, 6));
    Rank_Sum(7) = ranksum((All_Fitness(:, 8)), All_Fitness(:, 7));
    p_kw = kruskalwallis(All_Fitness, Method_name, 'off');
    if p_kw < 0.05
        disp(['Significant differences found for function: ', valid_func_name]);
        % Perform Dunn's post-hoc test using the multcompare function
        [~,~,stats] = kruskalwallis(All_Fitness, Method_name, 'off');
        c = multcompare(stats, 'ctype', 'dunn-sidak', 'Display', 'off');
        Result.(valid_func_name).DunnTest = c;
    else
        disp(['No significant differences found for function: ', valid_func_name]);
    end
    %% 将各个算法的平均排名、排名和总适应度值存入Result结构体中
    Result.(valid_func_name).AvgRank = Average_Rank;
    Result.(valid_func_name).Rank = Rank_Array;
    Result.(valid_func_name).All_Fitness = All_Fitness;
    Result.(valid_func_name).Rank_Sum = Rank_Sum;
    Result.(valid_func_name).p_kw = p_kw;
end
toc;
disp(['Time cost: ', num2str(toc), 's']);
% 保存结果
IEEE118_topo_Result = Result;
save('IEEE118_topo_Result.mat', 'IEEE118_topo_Result');
