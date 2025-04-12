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
function [BestF, BestX, HisBestF]=QIO(BenFunctions, Low, Up, Dim, nPop, MaxIt)
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
IndividualsPos = zeros(nPop, Dim);    % 初始化种群位置
IndividualsFit = zeros(nPop, 1);      % 初始化种群适应度
% 如果上下界是一维的，扩展到多维
if isscalar(Low)
    Low = ones(1, Dim) * Low;
    Up = ones(1, Dim) * Up;
end
for i=1:nPop
    IndividualsPos(i,:)=rand(1,Dim).*(Up-Low)+Low;
    IndividualsFit(i)=BenFunctions(IndividualsPos(i,:));
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
    for i=1:nPop
        if rand<0.5 % 此阶段为探索
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

        %Eq.(33)
        if newIndividualFit<IndividualsFit(i)
            IndividualsFit(i)=newIndividualFit;
            IndividualsPos(i,:)=newIndividualPos;
        end
    end
    
    for i=1:nPop
        if IndividualsFit(i)<BestF
            BestF=IndividualsFit(i);
            BestX=IndividualsPos(i,:);
        end
    end
    
    HisBestF(It)=BestF;
end
disp(['QIO best solution = ', num2str(BestF)]);
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

function  X=SpaceBound(X,Up,Low)


    Dim=length(X);
    S=(X>Up)+(X<Low);    
    X=(rand(1,Dim).*(Up-Low)+Low).*S+X.*(~S);
end