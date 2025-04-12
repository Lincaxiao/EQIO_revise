%% 假定工作区存在名为 IEEE118_topo_Result 的变量
load('IEEE118_topo_Result.mat');
Test_name = ["118_Cost_Base", "118_Ploss", "118_Voltage_Deviation", ...
            "118_Cost_Ploss", "118_Cost_VD", "118_Cost_Ploss_VD"];
Test_name_fields = matlab.lang.makeValidName(Test_name);
All_Fitness = zeros(length(Test_name), 100, 8);
for i = 1:length(Test_name_fields)
    Tmp_array = IEEE118_topo_Result.(Test_name_fields{i}).All_Fitness;
    %% 先按照第8列的适应度值从小到大排序
    [~, Index] = sort(Tmp_array(:, 8));
    for j = 1:8
        All_Fitness(i, :, j) = Tmp_array(Index, j);
    end
end
%% 将 All_Fitness 转换为 Excel 文件，每个测试用例一个sheet，每个算法一列
% excel 文件名为 IEEE118_topo_Result.xlsx
% sheet 名称为 Test_name
% 第一行为 Method_name
Method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Method_name_fields = matlab.lang.makeValidName(Method_name);
Write_method_name = ["Grid index", "PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
for i = 1:length(Test_name)
    Tmp_array = zeros(100, 9);
    Tmp_array(:, 1) = 1:100;
    disp(size(All_Fitness(i, :, :)));
    Tmp_array(:, 2:9) = All_Fitness(i, :, :);
    Tmp_table = array2table(Tmp_array, 'VariableNames', Write_method_name);
    Tmp_table.Properties.VariableNames = Write_method_name;
    if i == 1
        writetable(Tmp_table, 'IEEE118_topo_Result.xlsx', 'Sheet', Test_name_fields{i});
    else
        writetable(Tmp_table, 'IEEE118_topo_Result.xlsx', 'Sheet', Test_name_fields{i}, 'WriteMode', 'append');
    end
end
