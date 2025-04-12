%% 用于得到各个算法的 Friedman Aligned Ranks
%% (4) Friedman aligned test (FAT) The FAT is expressed as [96]:

% $$FAT=\frac{(k-1)\left(\sum_{j=1}^kR_j^2-(kn^2/4)(kn+1)^2\right)}{kn(kn+1)(2kn+1)/6-1/k\sum_{i=1}^nR_i^2}$$
% where $R_i$ is the rank total of $i$th problem and $R_j$ is the rank total of $j$th algorithm, $k$ is the number of algorithms and $n$ is the number of problems. The smaller the average of $R_i$, the better the rank of the corresponding algorithm.
load('stored_arrays.mat', 'score_matrix');

Algorithms = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];

%% 从 score_matrix 中得到 rank 矩阵
% best_score 形状为 (F, dim, 8)
best_score = score_matrix(:, :, :);
rank_matrix = zeros(29, 3, 8);
for dim = 1:3
    for i = 1:29
        % 提取当前问题在当前维度下的所有算法得分
        current_scores = squeeze(best_score(i, dim, :));
        % 使用tiedrank计算排名(较小的值获得较小的排名)
        % 验证正确性
        rank_matrix(i, dim, :) = tiedrank(current_scores);
    end
end

FAT_alg = zeros(3, 1);
for dim = 1:3
    %% R_i 是 rank total of i-th problem
    R_i = zeros(29, 1);
    for i = 1:29
        R_i(i) = sum(rank_matrix(i, dim, :));
    end
    %% R_j 是 rank total of j-th algorithm
    R_j = zeros(29, 1,8);
    for j = 1:29
        for i = 1:8
            R_j(j, 1, i) = rank_matrix(j, dim, i);
        end
    end
    %% R_j 转换为 rank total of j-th algorithm: 1x8
    R_j = reshape(sum(R_j, 1),8, 1);
    k = 8;
    n = 29;
    FAT_alg(dim) = (k-1) * (sum(R_j.^2) - (k*n^2/4)*(k*n+1)^2) / ...
                (k*n*(k*n+1)*(2*k*n+1)/6 - (1/k)*sum(R_i.^2));
end

disp(FAT_alg);