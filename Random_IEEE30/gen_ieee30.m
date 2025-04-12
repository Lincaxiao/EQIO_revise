%% 用来生成100张随机的IEEE30数据
seed = 1;
tmp = case_ieee30; % 获取 IEEE 30 数据的模板
Gen_IEEE30_Array = cell(1, 100); % 初始化单元格数组

for i = 1:100
    tmp = case_ieee30;
    bus = tmp.bus(:,3);
    %% 计算原始总负荷
    total_load = sum(bus);
    for j = 1:30
        seed = seed + 1;
        rng(seed); % 设置随机数种子
        bus(j) = bus(j)*0.75 + 0.5*rand*bus(j);
    end
    %% 计算新的总负荷
    new_total_load = sum(bus);
    %% 调整新的总负荷使之与原始总负荷相等
    bus = bus * total_load / new_total_load;
    tmp.bus(:,3) = bus;
    Gen_IEEE30_Array{i} = tmp; % 直接赋值给单元格数组
end

% 将单元格数组转换为结构数组
Gen_IEEE30_Array = cell2mat(Gen_IEEE30_Array);

save('Gen_IEEE30_Array.mat', 'Gen_IEEE30_Array');
