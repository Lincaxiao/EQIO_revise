function [Best_score, Best_pos, TSO_curve] = TSO(ObjFun, lowerbound, upperbound, dimension, SearchAgents, Max_iterations)
    % Initialize the lower and upper bounds
    lowerbound = ones(1, dimension) .* lowerbound;
    upperbound = ones(1, dimension) .* upperbound;
    
    % Follow degree
    a = 0.7;
    % Probability of random resetting
    z = 0.05;
    
    fitness = ObjFun;
    TSO_curve = NaN(Max_iterations, 1);
    % Initialize the population
    X = lowerbound + rand(SearchAgents, dimension) .* (upperbound - lowerbound); % 对种群进行随机初始化
    fit = arrayfun(@(i) fitness(X(i, :)), 1:SearchAgents); % 计算适应度并储存在fit中
    
    % Initialize best position and score
    [Best_score, best_idx] = min(fit);
    Best_pos = X(best_idx, :);
    
    % Main loop
    for t = 1:Max_iterations
        % Update follow degrees
        C = t / Max_iterations;
        a1 = a + (1 - a) * C; % a1 代表了个体向最优个体靠近的程度
        a2 = (1 - a) * (1 - C); 
        
        %%%% 是否可以像CSBO的静脉循环一样，接近最优个体，远离最差个体? %%%%
        %%%% 对每次个体更新计数，而不是每次迭代计数? %%%%

        % Update the population
        for i = 1:SearchAgents
            % 边界处理
            X(i, :) = min(max(X(i, :), lowerbound), upperbound);
            
            % Update fitness
            fit(i) = fitness(X(i, :));
            
            % Update the best position if needed
            if fit(i) < Best_score
                Best_score = fit(i);
                Best_pos = X(i, :);
            end
        end
        
        % Memory saving (if necessary) 在每次迭代中保证更好的解不会被覆盖
        if t == 1
            fit_old = fit;
            X_old = X;
        else
            for i = 1:SearchAgents
                if fit_old(i) < fit(i)
                    fit(i) = fit_old(i);
                    X(i, :) = X_old(i, :);
                end
            end
            X_old = X;
            fit_old = fit;
        end
        
        % t_factor 代表了时间因子，用于控制个体的移动速度
        t_factor = (1 - t / Max_iterations)^(t / Max_iterations);
        
        for i = 1:SearchAgents
            if rand < z       %%%% 是否可以先排序，选择最差的一部分个体进行重置 (不是随机)，参考CSBO，再在CSBO相关的部分中进行概率上的计算？%%%%
                              %%%% 这部分个体更适合较大的扰动 %%%%
                X(i, :) = lowerbound + rand(1, dimension) .* (upperbound - lowerbound);
            else              %%%% 那么这里就对应了CSBO中较好的那部分个体 %%%%
                if rand > 0.5
                    r1 = rand;
                    Beta = exp(r1 * exp(3 * cos(pi * (Max_iterations - t + 1) / Max_iterations))) * cos(2 * pi * r1);
                    if C > rand % 随着迭代次数的增加，个体的移动速度会减小
                        X(i, :) = a1 * (Best_pos + Beta * abs(Best_pos - X(i, :))) + a2 * X(i, :);
                    else 
                        IndivRand = lowerbound + rand(1, dimension) .* (upperbound - lowerbound); % 上下界生成的随机位置，代替了原来的最佳位置
                        X(i, :) = a1 * (IndivRand + Beta * abs(IndivRand - X(i, :))) + a2 * X(i, :); % 个体向随机位置靠近
                    end
                else
                    TF = (rand > 0.5) * 2 - 1; % 随机生成1或-1
                    if rand < 0.5 % 个体向最优个体靠近
                        X(i, :) = Best_pos + rand(1, dimension) .* (Best_pos - X(i, :)) + TF * t_factor^2 .* (Best_pos - X(i, :));
                    else % 个体向随机位置靠近
                        X(i, :) = TF * t_factor^2 .* X(i, :);
                    end
                end
            end
        end
        
        % Store the best fitness value for convergence curve
        TSO_curve(t) = Best_score;
    end
    disp(['TSO best solution = ' num2str(Best_score)]);
end
