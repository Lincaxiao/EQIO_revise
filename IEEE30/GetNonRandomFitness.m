
%% * 获取IEEE30的各个case的适应度值
load('IEEE30_non_random_multi_Result.mat');
Test_name = ["30_Cost_with_Tax", "30_Ploss", ...
    "30_Voltage_Deviation", "30_Cost_Ploss", "30_Cost_VD", "30_Cost_Tax_Ploss_VD"];
%Method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Method_name = ["PSO", "TSO", "PO", "CPO", "PLO", "TLBO", "QIO", "EQIO"];
Test_name_fields = matlab.lang.makeValidName(Test_name);
Method_name_fields = matlab.lang.makeValidName(Method_name);
%Write_method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Write_method_name = ["PSO", "TSO", "PO", "CPO", "PLO", "TLBO", "QIO", "EQIO"];

% * 从IEEE30_non_random_Result中获取适应度值
Fitness = zeros(length(Test_name), length(Method_name));
Mean_Fitness = zeros(length(Test_name), length(Method_name));
Std_Fitness = zeros(length(Test_name), length(Method_name));
Worst_Fitness = zeros(length(Test_name), length(Method_name));
for i = 1:length(Test_name)
    for j = 1:length(Method_name)
        Fitness(i, j) = IEEE30_non_random_multi_Result.(Test_name_fields(i)).(Method_name_fields(j)).Best_fitness;
        Mean_Fitness(i, j) = IEEE30_non_random_multi_Result.(Test_name_fields(i)).(Method_name_fields(j)).Mean;
        Std_Fitness(i, j) = IEEE30_non_random_multi_Result.(Test_name_fields(i)).(Method_name_fields(j)).Std;
        Worst_Fitness(i, j) = IEEE30_non_random_multi_Result.(Test_name_fields(i)).(Method_name_fields(j)).Worst_fitness;
    end
end

% * 存入excel文件，文件名为IEEE30_non_random_Fitness.xlsx
File_name = "IEEE30_non_random_Fitness.xlsx";
% * 写入最优值，平均值，最差值，方差
% * 第一行是算法名，从 B1 开始
% * 第一列变量名，从 B2 开始，Best_fitness, Mean, Worst_fitness, Std，共4行
% * A2:A5 分别是 Best_fitness, Mean, Worst_fitness, Std
for i = 1:length(Test_name)
    Sheet_name = Test_name(i);
    Data = [Fitness(i, :); Mean_Fitness(i, :); Worst_Fitness(i, :); Std_Fitness(i, :)];
    % * 写入数据
    writematrix(Write_method_name, File_name, 'Sheet', Sheet_name, 'Range', 'B1:I1');
    % * 写入变量名称
    Variable_names = {'Best_fitness'; 'Mean'; 'Worst_fitness'; 'Std'};
    writecell(Variable_names, File_name, 'Sheet', Sheet_name, 'Range', 'A2');
        
    writematrix(Data, File_name, 'Sheet', Sheet_name, 'Range', 'B2');
end
