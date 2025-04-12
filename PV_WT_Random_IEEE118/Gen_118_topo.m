%% 118节点一共有186条支路
seed = 1;
%Gen_IEEE118_Array = cell(1, 186); % 初始化单元格数组
Gen_IEEE118_Array = cell(1, 100); % 初始化单元格数组
%% 遍历118节点系统所有支路，将每一条支路进行分类
%% PV-PV, PV-PQ, Slack-PQ, Slack-PV, PQ-PQ
PV_PV = []; PV_PQ = []; Slack_PQ = []; Slack_PV = []; PQ_PQ = [];
bus_type = [1, 2, 3, 4, 5];
bus = case118().bus(:, 2);
branch = case118().branch;
for i = 1:186
    single_branch = branch(i, :);
    from = single_branch(1);
    from_type = bus(from);
    to = single_branch(2);
    to_type = bus(to);
    % 1是PQ节点，2是PV节点，3是Slack节点
    if from_type == 1 && to_type == 1
        PQ_PQ = [PQ_PQ, i];
    elseif (from_type == 1 && to_type == 2) || (from_type == 2 && to_type == 1)
        PV_PQ = [PV_PQ, i];
    elseif (from_type == 2 && to_type == 2)
        PV_PV = [PV_PV, i];
    elseif (from_type == 3 && to_type == 1) || (from_type == 1 && to_type == 3)
        Slack_PQ = [Slack_PQ, i];
    elseif (from_type == 3 && to_type == 2) || (from_type == 2 && to_type == 3)
        Slack_PV = [Slack_PV, i];
    end
end
% 打印PV-PV的支路编号
disp(['PV-PV: ', num2str(PV_PV)]);
% 打印PV-PQ的支路编号
disp(['PV-PQ: ', num2str(PV_PQ)]);
% 打印Slack-PQ的支路编号
disp(['Slack-PQ: ', num2str(Slack_PQ)]);
% 打印Slack-PV的支路编号
disp(['Slack-PV: ', num2str(Slack_PV)]);
% 打印PQ-PQ的支路编号
disp(['PQ-PQ: ', num2str(PQ_PQ)]);
%% 求和
total = length(PV_PV) + length(PV_PQ) + length(Slack_PQ) + length(Slack_PV) + length(PQ_PQ);
fprintf('Total: %d\n', total);

for index = 1:100%1:186
    tmp = case118;
    %tmp.branch(index, 11) = 0; % 使得线路断开
    %% 计算原始总负荷
    total_load = sum(tmp.bus(:,3));
    for j = 1:118
        seed = seed + 1;
        rng(seed); % 设置随机数种子
        tmp.bus(j, 3) = tmp.bus(j, 3)*0.75 + 0.5*rand*tmp.bus(j, 3);
    end
    %% 计算新的总负荷
    new_total_load = sum(tmp.bus(:,3));
    %% 调整新的总负荷使之与原始总负荷相等
    tmp.bus(:,3) = tmp.bus(:,3) * total_load / new_total_load;
    Gen_IEEE118_Array{index} = tmp; % 直接赋值给单元格数组
end
%% 根据Slack-PV, Slack-PQ, PV-PQ, PV-PV, PQ-PQ的顺序进行保存
%Gen_IEEE118_Array = Gen_IEEE118_Array([Slack_PV, Slack_PQ, PV_PQ, PV_PV, PQ_PQ]);
%% 按顺序一个一个保存到"Data/IEEE118_Topo_{index}.mat"文件中
for index = 1:100%186
    %% 创建合适的变量名字
    valid_func_name = genvarname(['IEEE118_Topo_', num2str(index)]);
    %% 提取单个结构体
    data = Gen_IEEE118_Array{index};
    %% 保存到文件中
    save(['Data/IEEE118_Topo_', num2str(index), '.mat'], 'data');
end