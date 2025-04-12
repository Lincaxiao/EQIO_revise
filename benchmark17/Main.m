clear;
clc
close all;

pop_size = 30; % 种群数目
max_iter = 1000; % 迭代次数

run = 30; % 运行次数
F = [1 3 4 5 6 7 8 9 10 11 12 ...
    13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30];%第二个函数被删除
dim_case = [30, 50, 100]; % 可选 30, 50, 100
%% 如果不存在"stored_arrays.mat"文件
if ~exist('stored_arrays.mat', 'file')
    %% 建立一个储存迭代曲线的矩阵（只储存最优的一次）
    curve_matrix = zeros(length(F), length(dim_case), 8, max_iter);
    %% 建立一个储存所有结果的矩阵
    result_matrix = zeros(length(F), length(dim_case), 8, run);
    %% 建立一个储存最优值的矩阵
    score_matrix = zeros(length(F), length(dim_case), 8);
    %% 建立一个储存平均值的矩阵
    mean_matrix = zeros(length(F), length(dim_case), 8);
    %% 建立一个储存标准差的矩阵
    std_matrix = zeros(length(F), length(dim_case), 8);
    %% 建立一个储存秩和检验结果的矩阵，检验EAPO与其他算法的差异
    rank_sum_RESULT = zeros(length(F), length(dim_case), 7);
else
    load('stored_arrays.mat');
end
%%% GA, ABC, GWO ==> PO, CPO, PLO
Algorithms = ["PSO", "TSO", "PO", "CPO", "PLO", "TLBO", "QIO", "EQIO"];
for h = 3:3%1:length(dim_case)
    nVar = dim_case(h);
    for i = 2:2%1:length(F)
        number = F(i);
        [lower_bound,upper_bound,dim,fobj]=Get_Functions_cec2017(number,nVar);
        for j = 1:run
            %% 从Algorithms中选择一个算法
            disp(['Running F', num2str(number), ' in ', num2str(nVar), ' dimensions, run ', num2str(j)]);
            %[PSO_score, ~, PSO_curve] = PSO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            % [TSO_score, ~, TSO_curve] = TSO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            % [TLBO_score, ~, TLBO_curve] = TLBO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            % [QIO_score, ~, QIO_curve] = QIO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            % [EQIO_score, ~, EQIO_curve] = EQIO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            %% 除了 PO, CPO, PLO, 其他算法的结果已经在 result_matrix 中
            PSO_score = result_matrix(i, h, 1, j) + 100 * F(i);
            TSO_score = result_matrix(i, h, 2, j) + 100 * F(i);

            [PO_score, ~, PO_curve] = PO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            [CPO_score, ~, CPO_curve] = CPO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            [PLO_score, ~, PLO_curve] = PLO(fobj, lower_bound, upper_bound, dim, pop_size, max_iter);
            TLBO_score = result_matrix(i, h, 6, j) + 100 * F(i);
            QIO_score = result_matrix(i, h, 7, j) + 100 * F(i);
            EQIO_score = result_matrix(i, h, 8, j) + 100 * F(i);
            %% 将结果存入矩阵
            % result_matrix(i, h, 1, j) = PSO_score - 100 * F(i);
            % result_matrix(i, h, 2, j) = TSO_score - 100 * F(i);
            % result_matrix(i, h, 3, j) = GA_score - 100 * F(i);
            % result_matrix(i, h, 4, j) = ABC_score - 100 * F(i);
            % result_matrix(i, h, 5, j) = GWO_score - 100 * F(i);
            % result_matrix(i, h, 6, j) = TLBO_score - 100 * F(i);
            % result_matrix(i, h, 7, j) = QIO_score - 100 * F(i);
            % result_matrix(i, h, 8, j) = EQIO_score - 100 * F(i);
            result_matrix(i, h, 3, j) = PO_score;
            result_matrix(i, h, 4, j) = CPO_score;
            result_matrix(i, h, 5, j) = PLO_score;
            %% 存储迭代曲线
            for k = 1:8
                if k <= 2 || k >= 6
                    continue; % 跳过GA, ABC, GWO
                end
                current_score = result_matrix(i, h, k, j);
                if j == 1 || current_score < min(result_matrix(i, h, k, 1:j-1))
                    switch k
                        % case 1
                        %     curve_matrix(i, h, k, :) = PSO_curve;
                        % case 2
                        %     curve_matrix(i, h, k, :) = TSO_curve;
                        case 3
                            curve_matrix(i, h, k, :) = PO_curve;
                        case 4
                            curve_matrix(i, h, k, :) = CPO_curve;
                        case 5
                            curve_matrix(i, h, k, :) = PLO_curve;
                        % case 6
                        %     curve_matrix(i, h, k, :) = TLBO_curve;
                        % case 7
                        %     curve_matrix(i, h, k, :) = QIO_curve;
                        % case 8
                        %     curve_matrix(i, h, k, :) = EQIO_curve;
                    end
                end
            end
        end
        %% 计算最优值、平均值、标准差
        for k = 1:8
            score_matrix(i, h, k) = min(result_matrix(i, h, k, :));
            mean_matrix(i, h, k) = mean(result_matrix(i, h, k, :));
            std_matrix(i, h, k) = std(result_matrix(i, h, k, :));
        end
        %% 秩和检验
        for k = 1:7
            rank_sum_RESULT(i, h, k) = ranksum(squeeze(result_matrix(i, h, 1, :)), squeeze(result_matrix(i, h, k+1, :)));
        end
        %% 打印在第h个维度下，"F_x"函数的最优算法
        [~, best_algorithm] = min(score_matrix(i, h, :));
        fprintf('In %d-dimension, the best algorithm for F%d is %s\n', nVar, number, Algorithms(best_algorithm));
        %% 打印EQIO和QIO的最优结果在所有算法的最优结果里相应的排名
        [~, rank] = sort(score_matrix(i, h, :));
        fprintf('EQIO is ranked %d, QIO is ranked %d\n', find(rank == 8), find(rank == 7));
        %% 打印三个 PO，CPO, PLO 算法的最优结果在所有算法的最优结果里相应的排名
        [~, rank] = sort(score_matrix(i, h, :));
        fprintf('PO is ranked %d, CPO is ranked %d, PLO is ranked %d\n', find(rank == 3), find(rank == 4), find(rank == 5));
    end
end
%% 先储存
save('stored_arrays.mat', 'curve_matrix', 'result_matrix', 'score_matrix', 'mean_matrix', 'std_matrix', 'rank_sum_RESULT');
