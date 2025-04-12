%%% Quadratic Interpolation Optimization (QIO) for 23 functions %%%
%--------------------------------------------------------------------------%
% Quadratic Interpolation Optimization (QIO)                               %
% Source codes demo version 1.0                                            %
% The code is based on the following paper:                                %
% W. Zhao, L. Wang, Z. Zhang, S. Mirjalili, N. Khodadadi, Q. Ge, Quadratic % 
% Interpolation Optimization (QIO): A new optimization algorithm based on  % 
% generalized quadratic interpolation and its applications to real-world   % 
% engineering problems, Computer Methods in Applied Mechanics and          %
% Engineering (2023) 116446, https://doi.org/10.1016/j.cma.2023.116446.    %
%--------------------------------------------------------------------------%
function [BestF, BestX, HisBestF]=EQIO(BenFunctions, Low, Up, Dim, nPop, MaxIt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FunIndex: 函数索引                              
% MaxIt: 最大迭代次数                             
% nPop: 种群大小                                  
% IndividualsPos: 个体种群的位置                   
% IndividualsFit: 个体种群的适应度                 
% Dim: 问题的维度                                 
% BestX: 迄今为止找到的最佳解                     
% BestF: 与 BestX 对应的最佳适应度。                
% HisBestF: 历史最佳适应度随迭代的变化            
% Low: 搜索空间的下界                           
% Up: 搜索空间的上界                              
% w1: 探索权重                                  
% w2: 开发权重                                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 将探索和开发阶段的选择由随机选择换成在排序后选择适应性最差的个体探索，适应度最好的个体开发


% 初始化参数和变量
IndividualsFit = zeros(nPop, 1);      % 初始化种群适应度
% 如果上下界是一维的，扩展到多维
if isscalar(Low)
    Low = ones(1, Dim) * Low;
    Up = ones(1, Dim) * Up;
end

%for i=1:nPop
%    IndividualsPos(i,:)=rand(1,Dim).*(Up-Low)+Low;
%    IndividualsFit(i)=BenFunctions(IndividualsPos(i,:),FunIndex,Dim);
%end
% 使用Tent混沌映射初始化种群位置
x = TentMap(nPop * Dim);
% 将一维位置向量转换为二维位置矩阵
x = reshape(x, nPop, Dim);
IndividualsPos = repmat(Low, nPop, 1) + x .* repmat(Up - Low, nPop, 1);
for i = 1:nPop
    IndividualsFit(i) = BenFunctions(IndividualsPos(i, :));
end

% 寻找初始最优解
BestF = inf;  % 将最佳适应度初始化为无穷大
BestX = [];

for i=1:nPop
    if IndividualsFit(i)<=BestF
        BestF=IndividualsFit(i);
        BestX=IndividualsPos(i,:);
    end
end

% 主优化循环
HisBestF = zeros(MaxIt, 1);  % 最佳适应度值的历史记录

for It=1:MaxIt
    newIndividualPos=zeros(1,Dim);
    % 探索和开发阶段的选择由随机选择换成在排序后选择适应性最差的个体
    % 将种群按适应度值从小到大排序
    [IndividualsFit, SortOrder]=sort(IndividualsFit);
    IndividualsPos=IndividualsPos(SortOrder,:);
    for i=1:nPop
        if i>=nPop/2
            % 此阶段为探索
            K=[1:i-1 i+1:nPop]; % 生成一个不包含 i 的随机序列
            RandInd=randperm(nPop-1,3); % 从 K 中随机选取 3 个索引 
            K1=K(RandInd(1));
            K2=K(RandInd(2));
            K3=K(RandInd(3));
            % 计算相应个体的适应度值
            f1=IndividualsFit(i); 
            f2=IndividualsFit(K1);
            f3=IndividualsFit(K2);
            
            for j=1:Dim
                x1=IndividualsPos(i,j); % 第 i 个个体的第 j 个维度的位置
                x2=IndividualsPos(K1,j);
                x3=IndividualsPos(K2,j);
                % Eq.(25)
                % 计算新个体的位置
                newIndividualPos(j)=GQI(x1,x2,x3,f1,f2,f3,Low(j),Up(j));
            end
            a=cos(pi/2*It/MaxIt);
            b=0.7*a+0.15*a*(cos(5*pi*It/MaxIt)+1);
            % Eq.(27)
            w1=3*b*randn;
            % Exploration, Eq.(26)
            newIndividualPos=newIndividualPos+w1.*(IndividualsPos(K3,:)-...
                newIndividualPos)+round(0.5*(0.05+rand))*(log(rand/(rand)));
        else
            K=[1:i-1 i+1:nPop];
            RandInd=randperm(nPop-1,2);
            K1=K(RandInd(1));
            K2=K(RandInd(2));
            f1=IndividualsFit(K1);
            f2=IndividualsFit(K2);
            f3=BestF;
            for j=1:Dim
                x1=IndividualsPos(K(RandInd(1)),j);
                x2=IndividualsPos(K(RandInd(2)),j);
                x3=BestX(j);
                %Eq.(31)
                newIndividualPos(j)=GQI(x1,x2,x3,f1,f2,f3,Low(j),Up(j));
            end
            %Eq.(32)
            w2=3*(1-(It-1)/MaxIt)*randn;
            rD=randi(Dim);
            %Exploitation, Eq.(30)
            
            newIndividualPos=newIndividualPos+w2*(BestX-round(1+rand)*...
                (Up-Low)/(Up(rD)-Low(rD))*IndividualsPos(i,rD));
            
        end
        newIndividualPos=SpaceBound(newIndividualPos,Up,Low);
        newIndividualFit=BenFunctions(newIndividualPos);

        %%%
        % 加入动态反向学习机制，更新个体适应度值和位置
        d_ub = zeros(1, Dim);
        d_lb = zeros(1, Dim);
        for j = 1:Dim
            d_ub(j) = max(IndividualsPos(:, j));
            d_lb(j) = min(IndividualsPos(:, j));
        end
        % 根据动态的最大最小值更新种群的适应度值和位置
        anti_NewIndividualPos = SpaceBound(d_lb + d_ub - newIndividualPos, Up, Low);
        anti_NewIndividualFit = BenFunctions(anti_NewIndividualPos);
        %%%%


        %Eq.(33)
        if newIndividualFit<IndividualsFit(i)
            IndividualsFit(i)=newIndividualFit;
            IndividualsPos(i,:)=newIndividualPos;
        end
        
        %%%
        if anti_NewIndividualFit<IndividualsFit(i)
            IndividualsFit(i)=anti_NewIndividualFit;
            IndividualsPos(i,:)=anti_NewIndividualPos;
        end
        %%%

    end
    
    for i=1:nPop
        if IndividualsFit(i)<BestF
            BestF=IndividualsFit(i);
            BestX=IndividualsPos(i,:);
        end
    end
    
    HisBestF(It)=BestF;
    disp(['EQIO iteration ', num2str(It), ' BestF = ', num2str(BestF)]);
end
%disp(['EQIO best solution = ',num2str(BestF)]);
end

function L=GQI(a,b,c,fa,fb,fc,low,up)
    %%%%%%%%%%%%%%% Generalized Quadratic Interpolation (GQI) %%%%%%%%%%%%%%%%%
    
    fabc=[fa fb fc];
    [fijk,ind]=sort(fabc);
    fi=fijk(1);fj=fijk(2);fk=fijk(3);
    dim=length(a);
    ai=ind(1); bi=ind(2);ci=ind(3);
    L=zeros(1,dim);
    for i=1:dim
        x=[a(i) b(i) c(i)];
        xi=x(ai); xj=x(bi); xk=x(ci);
        %Eq.(23)
        if (xk>=xi && xi>=xj) || (xj>=xi && xi>=xk)
            L(i)=Interpolation(xi,xj,xk,fi,fj,fk,low(i),up(i));
        %Eq.(19)
        elseif (xk>=xj && xj>=xi)        
            I=Interpolation(xi,xj,xk,fi,fj,fk,low(i),up(i));
            if  I<xj
                L(i)=I;
            else
                L(i)=Interpolation(xi,xj,3*xi-2*xj,fi,fj,fk,low(i),up(i));
            end
        %Eq.(20)
        elseif (xi>=xj && xj>=xk)
            I=Interpolation(xi,xj,xk,fi,fj,fk,low(i),up(i));
            if  I>xj
                L(i)=I;
            else
                L(i)=Interpolation(xi,xj,3*xi-2*xj,fi,fj,fk,low(i),up(i));
            end
        %Eq.(21)
        elseif (xj>=xk && xk>=xi)
            L(i)=Interpolation(xi,2*xi-xk,xk,fi,fj,fk,low(i),up(i));
        %Eq.(22)
        elseif (xi>=xk && xk>=xj)
            L(i)=Interpolation(xi,2*xi-xk,xk,fi,fj,fk,low(i),up(i));
        end
    end
end

function L_xmin=Interpolation(xi,xj,xk,fi,fj,fk,l,u)
%%%%%%%%%%%% Quadratic interpolation %%%%%%%%%%%
    %Eq.(5)
    a=(xj^2-xk^2)*fi+(xk^2-xi^2)*fj+(xi^2-xj^2)*fk;
    b=2*((xj-xk)*fi+(xk-xi)*fj+(xi-xj)*fk);

    L_xmin=a/(b+eps); 
    if isnan(L_xmin) || isinf(L_xmin) || L_xmin>u || L_xmin<l
        L_xmin=(rand*(u-l)+l);
    end
    
end

function x = TentMap(N)
    % Initialize the output array
    x = zeros(1, N);
    
    % Set the initial condition (can be adjusted if needed)
    x0 = 0.1;
    x(1) = x0;
    
    % Generate the Tent map sequence
    for i = 2:N
        if x(i-1) < 0.5
            x(i) = 2 * x(i-1);
        else
            x(i) = 2 * (1 - x(i-1));
        end
    end
    
    % Reshape the output to be in the form of a matrix if needed
    x = reshape(x, [], 1);
end

function  X=SpaceBound(X,Up,Low)


    Dim=length(X);
    S=(X>Up)+(X<Low);    
    X=(rand(1,Dim).*(Up-Low)+Low).*S+X.*(~S);
end