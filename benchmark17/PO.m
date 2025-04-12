%___________________________________________________________________________________________________________________________________________________%
% Parrot Optimizer (PO) source codes (version 2.0)
% PO
% Parrot optimizer: Algorithm and applications to medical problems
% Website and codes of Parrot optimizer(PO):http://www.aliasgharheidari.com/PO.html
function [Best_score, Best_pos, curve] = PO(fobj, lb, ub, dim, N, Max_iter)

% BestF: Best value in a certain iteration
% WorstF: Worst value in a certain iteration
% GBestF: Global best fitness value
% AveF: Average value in each iteration


ub = ub .* ones(1, dim);
lb = lb .* ones(1, dim);


%% Initialization
X0 = initialization(N, dim, ub, lb); % Initialization
X = X0;

% Compute initial fitness values
fitness = zeros(1, N);
for i = 1:N
    fitness(i) = fobj(X(i, :));
end
[fitness, index] = sort(fitness); % sort
GBestF = fitness(1); % Global best fitness value
AveF = mean(fitness);
for i = 1:N
    X(i, :) = X0(index(i), :);
end
curve = zeros(1, Max_iter);
avg_fitness_curve = zeros(1, Max_iter);
GBestX = X(1, :); % Global best position
X_new = X;
search_history = zeros(N, Max_iter, dim);
fitness_history = zeros(N, Max_iter);
%% Start search
for i = 1:Max_iter
    % if mod(i,100) == 0
    %   display(['At iteration ', num2str(i), ' the fitness is ', num2str(curve(i-1))]);
    % end
    avg_fitness_curve(i) = AveF;
    alpha = rand(1) / 5;
    sita = rand(1) * pi;
    for j = 1:size(X, 1)
        St = randi([1, 4]);
        % foraging behavior
        if St == 1
                X_new(j, :) = (X(j, :) - GBestX) .* Levy(dim) + rand(1) * mean(X) * (1 - i / Max_iter) ^ (2 * i / Max_iter);

        % staying behavior
        elseif St == 2
                X_new(j, :) = X(j, :) + GBestX .* Levy(dim) + randn() * (1 - i / Max_iter) * ones(1, dim);

        % communicating behavior
        elseif St == 3
                H = rand(1);
                if H < 0.5
                    X_new(j, :) = X(j, :) + alpha * (1 - i / Max_iter) * (X(j, :) - mean(X));
                else
                    X_new(j, :) = X(j, :) + alpha * (1 - i / Max_iter) * exp(-j / (rand(1) * Max_iter));
                end
        % fear of strangers' behavior
        else
                X_new(j, :) = X(j, :) + rand() * cos((pi *i )/ (2 * Max_iter)) * (GBestX - X(j, :)) - cos(sita) * (i / Max_iter) ^ (2 / Max_iter) * (X(j, :) - GBestX);
        end

        % Boundary control
        for m = 1:N
            for a = 1:dim
                if (X_new(m, a) > ub(a))
                    X_new(m, a) = ub(a);
                end
                if (X_new(m, a) < lb(a))
                    X_new(m, a) = lb(a);
                end
            end
        end
       
        % Finding the best location so far
        if fobj(X_new(j, :)) < GBestF
            GBestF = fobj(X_new(j, :));
            GBestX = X_new(j, :);
        end

    end
    
    % Update positions
    for s = 1:N
        fitness_new(s) = fobj(X_new(s, :));
    end
    for s = 1:N
        if (fitness_new(s) < GBestF)
            GBestF = fitness_new(s);
            GBestX = X_new(s, :);
        end
    end
    X = X_new;
    fitness = fitness_new;
        
    % Sorting and updating
    [fitness, index] = sort(fitness); % sort
    for s = 1:N
        X0(s, :) = X(index(s), :);
    end
    X = X0;
    curve(i) = GBestF;
    Best_pos = GBestX;
    Best_score = curve(end);
    search_history(:, i, :) = X;
    fitness_history(:, i) = fitness;

end
disp(['PO: The best score is: ', num2str(Best_score)]);
end

%%  Levy search strategy
function o = Levy(d)
    beta = 1.5;
    sigma = (gamma(1 + beta) *sin(pi * beta / 2) / (gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)))^(1 / beta);
    u = randn(1, d) * sigma;
    v = randn(1, d);
    step = u ./ abs(v).^(1 / beta);
    o = step;
end   

function Positions=initialization(SearchAgents_no,dim,ub,lb)

    Boundary_no= size(ub,2); % numnber of boundaries
    
    % If the boundaries of all variables are equal and user enter a signle
    % number for both ub and lb
    if Boundary_no==1
        Positions=rand(SearchAgents_no,dim).*(ub-lb)+lb;
    end
    
    % If each variable has a different lb and ub
    if Boundary_no>1
        for i=1:dim
            ub_i=ub(i);
            lb_i=lb(i);
            Positions(:,i)=rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
        end
    end
end