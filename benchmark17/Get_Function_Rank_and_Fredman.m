load("stored_arrays.mat");
%% 定义算法名称和维度
% Algorithms = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Algorithms = ["PSO", "TSO", "PO", "CPO", "PLO", "TLBO", "QIO", "EQIO"];
dim_case = [30, 50, 100];
F = [1, 3:30]; % 移除第二个函数（2）

% rank_matrix(i, j, k) 表示第 i 个函数，在第 j 个维度下，第 k 个算法的排名
% 计算 rank_matrix，其中 score 越小排名越高
rank_matrix = zeros(29, 3, 8);
for i = 1:29
    for j = 1:3
        scores = squeeze(score_matrix(i, j, :));
        [~, idx] = sort(scores, 'ascend');
        ranks = 1:8; % 如果有不同数量的算法，使用 ranks = 1:length(scores);
        rank_matrix(i, j, idx) = ranks;
    end
end

%% 创建用于写入的数据表
num_functions = length(F);
num_dims = length(dim_case);
num_algorithms = length(Algorithms);

% 获取除 EQIO 之外的算法列表
other_algorithms = setdiff(Algorithms, "EQIO"); 
% 计算这些算法的数量
num_other_algorithms = length(other_algorithms);

% 初始化单元格数组，第一行是算法名称，第一列是 Fn_Dim
data = cell(num_functions * num_dims + 1, num_algorithms + 1);

% 填写算法名称（标题行），从第 B1 单元格开始
data(1, 2:end) = cellstr(Algorithms);

% 填写函数和维度组合（从 A2 单元格开始）
row = 2;
for i = 1:num_functions
    for j = 1:num_dims
        data{row, 1} = sprintf('F%d_%d', F(i), dim_case(j));
        row = row + 1;
    end
end

% 填写排名数据（从 B2 单元格开始）
row = 2;
for i = 1:num_functions
    for j = 1:num_dims
        % 获取当前函数和维度下的排名，排名越小表示性能越好
        ranks = squeeze(rank_matrix(i, j, :)); % rank_matrix 的维度为 (29, 3, 8)
        % 转换为行向量并填入数据
        data(row, 2:end) = num2cell(ranks');
        row = row + 1;
    end
end

%% 将数据写入 Excel 文件
filename = 'Algorithm_Rankings.xlsx';
writecell(data, filename);


% 获取 EQIO 的索引
EQIO_index = find(Algorithms == "EQIO");

%% 对于每个维度，计算并写入比较结果
for dim_idx = 1:num_dims
    dim = dim_case(dim_idx);

    % 初始化比较结果统计矩阵
    comparison_results = zeros(3, num_other_algorithms); % 行对应 Better, Equal, Worse

    for alg_idx = 1:num_other_algorithms
        alg = other_algorithms(alg_idx);
        alg_index = find(Algorithms == alg);
        better_count = 0;
        equal_count = 0;
        worse_count = 0;
        for func_idx = 1:num_functions
            EQIO_rank = rank_matrix(func_idx, dim_idx, EQIO_index);
            other_rank = rank_matrix(func_idx, dim_idx, alg_index);
            if EQIO_rank < other_rank
                better_count = better_count + 1;
            elseif EQIO_rank == other_rank
                equal_count = equal_count + 1;
            else
                worse_count = worse_count + 1;
            end
        end
        comparison_results(1, alg_idx) = better_count;
        comparison_results(2, alg_idx) = equal_count;
        comparison_results(3, alg_idx) = worse_count;
    end

    %% 准备写入 Excel 的数据
    data_comp = cell(4, num_other_algorithms + 1);
    data_comp(1, 2:end) = cellstr(other_algorithms);
    data_comp(2:end, 1) = {"Better"; "Equal"; "Worse"};
    data_comp(2:end, 2:end) = num2cell(comparison_results);

    %% 将比较结果写入新的工作表
    sheetname = sprintf('EQIO Comparison %d', dim);
    writecell(data_comp, filename, 'Sheet', sheetname);
end

%% 现在计算 Fredman Score
% Fredman Score 是 各个算法 在每个维度下的平均排名
fredman_scores = zeros(num_algorithms, num_dims);
Row = ["Algorithm", "30-Dim", "50-Dim", "100-Dim", "Mean"];
Column = Algorithms';

for alg_idx = 1:num_algorithms
    for dim_idx = 1:num_dims
        fredman_scores(alg_idx, dim_idx) = mean(squeeze(rank_matrix(:, dim_idx, alg_idx)));
    end
end
%% 计算平均 Fredman Score
mean_fredman_scores = mean(fredman_scores, 2);
% 将平均 Fredman Score 添加到 fredman_scores 中
fredman_scores = [fredman_scores, mean_fredman_scores];

% 准备写入 Excel 的数据
data_fredman = cell(num_algorithms + 1, num_dims + 2);

% 填写标题行
data_fredman(1, :) = cellstr(Row);

% 填写算法名称和 Fredman Scores
data_fredman(2:end, 1) = cellstr(Column);
data_fredman(2:end, 2:end) = num2cell(fredman_scores);

% 将 Fredman Scores 写入 Excel 文件
writecell(data_fredman, filename, 'Sheet', 'Fredman Scores');
