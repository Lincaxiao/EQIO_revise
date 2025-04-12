load("stored_arrays.mat", "score_matrix");

Algorithms = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
%% score_matrix 的形状为 (F, dim, 8)
Max_score = max(score_matrix, [], 3);
Min_score = min(score_matrix, [], 3);

range_matrix = Max_score - Min_score;
%% 构造 rank_matrix
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
n = 29;
k = 8;

for dim = 1:3
    for i = 1:29
        for j = 1:8
            S(i, j) = range_matrix(i, dim) * (rank_matrix(i, dim, j) - (1 + 8) / 2);
            W(i, j) = range_matrix(i, dim) * (rank_matrix(i, dim, j));
        end
    end
    for j = 1:8
        T(j) = sum(W(:, j)) / (n*(n+1)/2);
    end
    A = n*(n+1)*(2*n+1)*k*(k+1)*(k-1)/72;
    B = 1/n * sum(k* sum(S(:,j).^2));
    F_Q = (n - 1) * B / (A - B);
end