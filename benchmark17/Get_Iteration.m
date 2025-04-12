load("stored_arrays.mat");
%% 工作区现在有 curve_matrix 数组
Algorithms = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
max_iter = 1000;
%% Excel文件名为 CEC2017_Iteration.xlsx，分为3*29个sheet
filename = 'CEC2017_Iteration.xlsx';
dim = [30, 50, 100];
%% 1-30 except 2
Index_array = [1, 3:30];
%% function_name 是 F+数字, 数字是 1-30 except 2
function_name = arrayfun(@(x) ['F' num2str(x)], Index_array, 'UniformOutput', false);

for i = 1:3
    for j = 1:29
        % 生成工作表名称
        sheet_name = strcat(num2str(dim(i)), char(function_name(j)));

        % 创建表格数据
        data = zeros(max_iter + 1, 9); % 第一行 + 1000行
        data(1, 1) = "Iterations"; % 第一行第一个单元格
        data(1, 2:end) = Algorithms; % 第一行算法名称

        % 填充迭代次数和对应算法的迭代数据
        data(2:end, 1) = (1:max_iter)'; % 迭代次数
        for k = 1:8
            j_hot = j;
            data(2:end, k + 1) = squeeze(curve_matrix(j_hot, i, k, :)); % 填充数据
            %% 减去偏差值 F_n_min = n * 100
            data(2:end, k + 1) = data(2:end, k + 1) - 100 * Index_array(j);
        end

        % 写入Excel
        writematrix(data, filename, 'Sheet', sheet_name);
        % 在sheet的第一行写上 "Iterations" 和算法名称
        writematrix("Iterations", filename, 'Sheet', sheet_name, 'Range', 'A1');
        writematrix(Algorithms, filename, 'Sheet', sheet_name, 'Range', 'B1:I1');
    end
end