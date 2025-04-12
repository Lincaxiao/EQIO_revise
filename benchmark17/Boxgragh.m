%% 获取箱线图所需要的数据
load("stored_arrays.mat");
%% 具有 result_matrix，维度为 (29, 3, 8, 30)
% 29 个函数，3 个维度，8 种算法，30 次运行

%% 需要将 F1, F4, F15, F28 的数据提取出来
% F1, F4, F15, F28 的索引分别为 1, 3, 14, 27
% 3 个维度分别为 30, 50, 100
% 8 种算法分别为 EAPO, PSO, TLBO, PLO, HGS, MGO, SMA, APO
% Excel 文件名为 Boxgragh.xlsx，分为 3*4 个 sheet
filename = 'Boxgragh.xlsx';
dim = [30, 50, 100];
function_name = ["F1", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", ...
    "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19", ...
    "F20", "F21", "F22", "F23", "F24", "F25", "F26", "F27", "F28", ...
    "F29", "F30"];
Write_algorithm_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
for i = 1:3
    for j = 1:29
        % 生成工作表名称
        sheet_name = strcat(num2str(dim(i)), char(function_name(j)));
        %% 第一行从新sheet的 'A1' 开始，填充算法名称
        writematrix(Write_algorithm_name, filename, 'Sheet', sheet_name, 'Range', 'A1:H1');
        %% 填充数据，先填充到一个大的矩阵中，再写入Excel
        data = zeros(30, 8);
        for k = 1:8
            data(:, k) = squeeze(result_matrix(j, i, k, :));
        end
        writematrix(data, filename, 'Sheet', sheet_name, 'Range', 'A2:H31');
    end
end
