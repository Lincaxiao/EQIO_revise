%% * 获取与排名有关的数据，包括各个case中的最大值，最小值，平均值；平均排名，第一率，前三率
% *  以及DunnTest
% *  假定 IEEE30_random_Result 已经被加载
load('IEEE30_random_Result.mat');
Test_name = ["30_Cost_with_Tax","30_Ploss", "30_Voltage_Deviation", "30_Cost_Ploss", "30_Cost_VD", "30_Cost_Tax_Ploss_VD"];
Method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];
Write_method_name = ["PSO", "TSO", "GA", "ABC", "GWO", "TLBO", "QIO", "EQIO"];

% 将 Test_name 和 Method_name 转换为有效的字段名称
Test_name_fields = matlab.lang.makeValidName(Test_name);
Method_name_fields = matlab.lang.makeValidName(Method_name);

%% * 文件名为 IEEE30_Rank_Data.xlsx，每个sheet对应一个测试用例
for i = 1:length(Test_name)
    % * 读取数据
    Tmp = IEEE30_random_Result.(Test_name_fields(i)); % * 读取对应测试用例的数据
    DunnTest_array = Tmp.DunnTest; % * 读取DunnTest数据
    Rank_array = Tmp.Rank; % * 读取排名数据
    Average_rank_array = Tmp.AvgRank; % * 读取平均排名数据
    Max_array = NaN(1, 8); % * 用于存储最大值
    Min_array = NaN(1, 8); % * 用于存储最小值
    Mean_array = NaN(1, 8); % * 用于存储平均值
    First_rate_array = NaN(1, 8); % * 用于存储第一率
    Top_three_rate_array = NaN(1, 8); % * 用于存储前三率
    for j = 1:8
        Fit_array = Tmp.(Method_name_fields(j)).best_fit; % * 读取对应算法的适应度值
        % * 去除NaN
        Fit_array(isnan(Fit_array)) = [];
        % * 计算最大值，最小值，平均值
        Max_array(j) = max(Fit_array);
        Min_array(j) = min(Fit_array);
        Mean_array(j) = mean(Fit_array);
        % * 计算第一率，前三率：通过Rank_array (n*8) 计算
        First_rate_array(j) = nnz(Rank_array(:, j) == 1) / size(Rank_array, 1);
        Top_three_rate_array(j) = nnz(Rank_array(:, j) <= 3) / size(Rank_array, 1);
    end
    %% * B1:I1 为算法名，A2:A4 为最大值，最小值，平均值， A5:A7 Average_rank, First_rate, Top_three_rate
    Sheet_name = Test_name_fields(i);
    % 创建指标名称和算法名称
    Indicator_names = {'Max', 'Min', 'Mean', 'Average_rank', 'First_rate', 'Top_three_rate'}';
    Algorithm_names = Write_method_name;

    % 构建数据矩阵（6×8）
    Data_matrix = [Max_array; Min_array; Mean_array; Average_rank_array; First_rate_array; Top_three_rate_array];

    % 将指标名称和数据矩阵合并（6×9）
    Data_cell = [Indicator_names, num2cell(Data_matrix)];

    % 构建表格
    T = cell2table(Data_cell, 'VariableNames', ['Indicator', Algorithm_names]);
    writetable(T, 'IEEE30_Rank_Data.xlsx', 'Sheet', Sheet_name, 'Range', 'A1');
    % * 写入DunnTest，先去除DunnTest的第3 4 5列
    DunnTest_array(:, 3:5) = [];
    % * 写入DunnTest
    % * 在 A8 处写入 "DunnTest"
    writematrix("DunnTest", 'IEEE30_Rank_Data.xlsx', 'Sheet', Sheet_name, 'Range', 'A8');
    % * 在 A9 处写入数据，先把数据转换为cell，再将cell第一列和第二列的数字作为索引，用算法名替换
    DunnTest_cell = num2cell(DunnTest_array);
    % 替换 DunnTest_cell 第一列和第二列的数字为算法名称
    for k = 1:size(DunnTest_cell, 1)
        DunnTest_cell{k, 1} = Algorithm_names{DunnTest_cell{k, 1}};
        DunnTest_cell{k, 2} = Algorithm_names{DunnTest_cell{k, 2}};
    end
    % 写入 DunnTest
    writecell(DunnTest_cell, 'IEEE30_Rank_Data.xlsx', 'Sheet', Sheet_name, 'Range', 'A9');
end
