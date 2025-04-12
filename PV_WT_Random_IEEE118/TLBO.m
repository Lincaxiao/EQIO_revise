function [Best_score, Best_pos, TLBO_curve] = TLBO(ObjFun, lowerbound, upperbound, dimension, SearchAgents, Max_iterations)

    fitness = ObjFun;
    % 变量下界初始化
    lowerbound = ones(1,dimension).*(lowerbound);
    % 变量上界初始化
    upperbound = ones(1,dimension).*(upperbound);

    X = zeros(SearchAgents, dimension);
    fit = NaN(SearchAgents, 1);
    %% 初始化
    for i = 1:dimension
        % 初始种群生成
        X(:,i) = lowerbound(i) + rand(SearchAgents,1).*(upperbound(i)-lowerbound(i));
    end

    % 计算初始种群的适应度值
    for i = 1:SearchAgents
        L = X(i,:);
        fit(i) = fitness(L);
    end

    %% 主循环
    for t = 1:Max_iterations
        %% 更新最佳候选解
        [best,location] = min(fit);
        % 初始化最优位置和最优目标函数值
        if t == 1
            Xbest = X(location,:);  % 最优位置
            fbest = best;           % 优化目标函数值
        elseif best < fbest
            fbest = best;
            Xbest = X(location,:);
        end

        %% 教学阶段
        % 老师是种群内的最佳个体
        Teacher = Xbest;
        % 班级平均成绩
        Mean_X = mean(X);
        % 学生根据老师的位置以及班级平均成绩进行位置更新
        for i = 1:SearchAgents
            % 生成随机数
            r = rand;
            % TF 为教学因子，随机确定为1或2
            TF = randi([1,2]);
            % 更新位置
            X(i,:) = X(i,:) + r.*(Teacher - TF.*Mean_X);
            % 越界处理
            X(i,:) = min(max(X(i, :), lowerbound), upperbound);
            % 计算适应度值
            L = X(i,:);
            fit(i) = fitness(L);
            if fit(i) < fbest
                Xbest = X(i,:);
                fbest = fit(i);
            end
        end

        %% 学习阶段
        % 随机选择两个个体
        r1 = randi([1,SearchAgents]);
        r2 = randi([1,SearchAgents]);
        % 选择两个个体中适应度值较好的个体
        for i = 1:10
            if fit(r1) < fit(r2)
                % r2向r1学习
                X(r2,:) = X(r2,:) + rand.*(X(r1,:) - X(r2,:));
                X(r2,:) = min(max(X(r2, :), lowerbound), upperbound);
                L = X(r2,:);
                fit(r2) = fitness(L);
                if fit(r2) < fbest
                    Xbest = X(r2,:);
                    fbest = fit(r2);
                end
            else
                % r1向r2学习
                X(r1,:) = X(r1,:) + rand.*(X(r2,:) - X(r1,:));
                X(r1,:) = min(max(X(r1, :), lowerbound), upperbound);
                L = X(r1,:);
                fit(r1) = fitness(L);
                if fit(r1) < fbest
                    Xbest = X(r1,:);
                    fbest = fit(r1);
                end
            end
        end
        % 记录每次迭代的最优值
        best_so_far(t) = fbest;
        disp(['TLBO Iteration ' num2str(t) ': Best fitness = ' num2str(best_so_far(t))]);

        % 输出最佳得分、最佳位置和TLBO曲线
        Best_score = fbest;
        Best_pos = Xbest;
        TLBO_curve = best_so_far;
    end
end
