%% 获取IEEE118的迭代曲线
%% 假设工作区已经有一个名为IEEE118_non_random_multi_Result的变量
load("IEEE118_non_random_multi_Result.mat");
Test_name = ["118_Cost_Base", "118_Ploss", "118_Voltage_Deviation",...
            "118_Cost_Ploss", "118_Cost_VD", "118_Cost_Ploss_VD"];
% Method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Method_name = ["PSO", "TSO", "PO", "CPO", "PLO", "TLBO", "QIO", "EQIO"];
Test_name_fields = matlab.lang.makeValidName(Test_name);
Method_name_fields = matlab.lang.makeValidName(Method_name);
% Write_method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Write_method_name = ["PSO", "TSO", "PO", "CPO", "PLO", "TLBO", "QIO", "EQIO"];

% 从IEEE118_non_random_Result中获取迭代曲线
Iteration_Curve = zeros(length(Test_name), length(Method_name), 150);
for i = 1:length(Test_name)
    for j = 1:length(Method_name)
        Iteration_Curve(i, j, :) = IEEE118_non_random_multi_Result.(Test_name_fields{i}).(Method_name_fields{j}).Best_Iteration_Curve;
    end
end
%% 存入名为 "IEEE118_non_random_Iteration_Curve.xlsx" 的Excel文件中
file_name = 'IEEE118_non_random_Iteration_Curve.xlsx';
for i = 1:length(Test_name)
    sheet_name = Test_name{i};
    data = reshape(Iteration_Curve(i, :, :), [length(Method_name), 150]);
    data = permute(data, [2, 1]);
    %% 第一行是 "Iteration" + 方法名
    writematrix("Iterations", file_name, 'Sheet', sheet_name, 'Range', 'A1');
    writematrix(Write_method_name, file_name, 'Sheet', sheet_name, 'Range', 'B1:I1');
    %% 写入数据
    writematrix(data, file_name, 'Sheet', sheet_name, 'Range', 'B2');
    Iteration_Array = 1:150;
    writematrix(Iteration_Array', file_name, 'Sheet', sheet_name, 'Range', 'A2');
end
