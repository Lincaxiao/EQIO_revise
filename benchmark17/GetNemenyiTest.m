load('stored_arrays.mat', 'score_matrix');
k = 8;
n = 29;
alpha = 0.05;

best_score = score_matrix(:, :, :);
rank_matrix = zeros(29, 3, 8);
% Algorithms = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Algorithms = ["PSO", "TSO", "PO", "CPO", "PLO", "TLBO", "QIO", "EQIO"];
for dim =1:3
    %% 进行 Dunn 检验
    All_fitness = squeeze(best_score(:, dim, :));
    [p, table, stats] = friedman(All_fitness, 1, 'off');
    fprintf('In %d-dimension, the Friedman test p-value is %f\n', dim, p);
    if p < alpha
        fprintf('In %d-dimension, the Friedman test rejects the null hypothesis\n', dim);
        %% 进行 Nemenyi 后续检验
        [c, m, h, nms] = multcompare(stats, 'ctype', 'dunn-sidak', 'Display', 'off');
        for i = 1:size(c, 1)
            fprintf('The difference between %s and %s is %f\n', Algorithms(c(i, 1)), Algorithms(c(i, 2)), c(i, 3));
        end
    else
        fprintf('In %d-dimension, the Friedman test does not reject the null hypothesis\n', dim);
    end
end
