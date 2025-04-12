load("stored_arrays.mat");
% * 工作区有 mean_matrix: (29, 3, 8), std_matrix: (29, 3, 8), score_matrix: (29, 3, 8)
% * 文件名为 AvgStdBest.xlsx，分为 29 个 sheet, sheet 名字是 "F"+数字, 数字是 1-30 except 2
Row = ["Algorithm", "30-Best", "30-Mean", "30-Std", "50-Best", "50-Mean", "50-Std", "100-Best", "100-Mean", "100-Std"];
Column = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
% * 生成工作表名称
File_name = 'AvgStdBest1.xlsx';
Data_matrix = ones(3*8, 12);
F = [2, 5, 19, 23];

%% Data_matrix 1-3 行 PSO: Best, Mean, Std,...以此类推
%% Data_matrix 1-3 列 F3(index=2) Dim30, Dim50, Dim100,...以此类推
for i = 1:4
    F_index = F(i);
    for j = 1:3
        for k = 1:8
            Data_matrix(3*(k-1)+1, 3*(i-1)+j) = score_matrix(F_index, j, k);
            Data_matrix(3*(k-1)+2, 3*(i-1)+j) = mean_matrix(F_index, j, k);
            Data_matrix(3*(k-1)+3, 3*(i-1)+j) = std_matrix(F_index, j, k);
        end
    end
end

%% 第一行是 Algorithm，F3-D30, F3-D50, F3-D100, F6-D30, F6-D50, F6-D100, F20-D30, F20-D50, F20-D100, F24-D30, F24-D50, F24-D100
% * 逐个写入，先写入第一行
Row = ["Algorithm", "F3-D30", "F3-D50", "F3-D100", "F6-D30", "F6-D50", "F6-D100", "F20-D30", "F20-D50", "F20-D100", "F24-D30", "F24-D50", "F24-D100"];
writematrix(Row, File_name, 'Sheet', 'Sheet1', 'Range', 'A1:M1');
Column = ["PSO-Best", "PSO-Mean", "PSO-Std", "TSO-Best", "TSO-Mean", "TSO-Std", ...
    "GA-Best", "GA-Mean", "GA-Std", "ABC-Best", "ABC-Mean", "ABC-Std", ...
    "GWO-Best", "GWO-Mean", "GWO-Std", "TLBO-Best", "TLBO-Mean", "TLBO-Std", ...
    "QIO-Best", "QIO-Mean", "QIO-Std", "EQIO-Best", "EQIO-Mean", "EQIO-Std"];
% * 再写入第一列
writematrix(Column', File_name, 'Sheet', 'Sheet1', 'Range', 'A2:A25');
% * 最后写入数据
writematrix(Data_matrix, File_name, 'Sheet', 'Sheet1', 'Range', 'B2:M25'); % 为什么是J9，不是I9？答：
