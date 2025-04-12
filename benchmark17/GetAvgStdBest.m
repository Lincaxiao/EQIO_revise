load("stored_arrays.mat");
% * 工作区有 mean_matrix: (29, 3, 8), std_matrix: (29, 3, 8), score_matrix: (29, 3, 8)
% * 文件名为 AvgStdBest.xlsx，分为 29 个 sheet, sheet 名字是 "F"+数字, 数字是 1-30 except 2
Row = ["Algorithm", "30-Best", "30-Mean", "30-Std", "50-Best", "50-Mean", "50-Std", "100-Best", "100-Mean", "100-Std"];
Column = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
% * 生成工作表名称
File_name = 'AvgStdBest.xlsx';
Data_matrix = zeros(8, 9);
F = [1, 3:30];
for i = 1:29
    sheetname = "F" + num2str(F(i));
    for j = 1:3
        for k = 1:8
            Data_matrix(k, 3*j-2) = score_matrix(i, j, k);
            Data_matrix(k, 3*j-1) = mean_matrix(i, j, k);
            Data_matrix(k, 3*j) = std_matrix(i, j, k);
        end
    end
    % * 逐个写入，先写入第一行
    writematrix(Row, File_name, 'Sheet', sheetname, 'Range', 'A1:J1');
    % * 再写入第一列
    writematrix(Column', File_name, 'Sheet', sheetname, 'Range', 'A2:A9');
    % * 最后写入数据
    writematrix(Data_matrix, File_name, 'Sheet', sheetname, 'Range', 'B2:J9'); % 为什么是J9，不是I9？答：
end
