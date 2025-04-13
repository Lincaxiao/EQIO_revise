%% Dream-Optimization-Algorithm-DOA
function [fbest,sbest,fbest_history] = DOA(fobj,lb,ub,D,pop,T)
%pop stands for population size
%T represents the maximum number of population iteration
%lb represents the lower bound of the search space
%ub represents the upper bound of the search space
%D represents the dimension of the problem
%fobj represents the objective function

lb=lb.*ones(1,D);
ub=ub.*ones(1,D);                            %Ensure that the dimensions of the upper and lower bounds match the dimensionality of the problem
x =initialization(pop,D,ub,lb);              %Initialize the population
SELECT=1:pop;                                      
sbest=ones(1,D);                             %sbest is the current optimal solution
sbestd=ones(5,D);                            %sbestd represents the current optimal solution for each of the 5 groups
fbest=inf;                                   %fbest is the current optimal value
fbestd=ones(5,1);                            %fbestd represents the current optimal value for each of the 5 groups
fbest_history=ones(1,T);                     %fbest_history is a vector composed of the best values of each generation

for i = 1:5
      fbestd(i)=fbest;
end   
              
for i=1:(9*T/10)                                               %Exploration phase
      for m=1:5                                                %Divide into 5 groups       
         k=randi([ceil(D/8/m),ceil(D/3/m)]);            
         for j=(((m-1)/5*pop)+1) : (m/5*pop)                 
                     if (fobj(x(j,:)) <fbestd(m))
                      sbestd(m,:)=x(j,:);                         
                      fbestd(m)=fobj(x(j,:));                  %Update the optimal value and solution for each group
                     end
         end
          for j=(((m-1)/5*pop)+1) : (m/5*pop)
           x(j,:)=sbestd(m,:);                                  %Memory strategy
           in=randperm(D,k);        
           if rand<0.9
               for h=1:k
                   x(j,in(h))=x(j,in(h))+(rand*(ub(in(h))-lb(in(h)))+lb(in(h)))*(cos((1*i+T/10)*pi/T)+1)/2;      %Forgetting and supplementation strategy
                if (x(j,in(h))>ub(in(h))) | (x(j,in(h))<lb(in(h)))   
                    if D>15                                      %The boundary handling method when the problem dimensionality>15
                     select=SELECT;     
                     select(j)=[];
                     sel=select(randi(pop-1));                             
                     x(j,in(h))=x(sel,in(h)); 
                    else                                          %The boundary handling method when the problem dimensionality<=15
                     x(j,in(h))=rand*(ub(in(h))-lb(in(h)))+lb(in(h));                
                    end  
                 end
               end
            else
               for h=1:k                       
                   x(j,in(h))=x(randi(pop),in(h));                                      
               end
            end
          end     
            if (fbestd(m)<fbest)            %Update the optimal value and solution for the entire population
               fbest=fbestd(m);
               sbest=sbestd(m,:);
            end
      end                                               
fbest_history(i)=fbest;
%disp(['DOA Iteration ', num2str(i), ' Best fitness: ', num2str(fbest)]);                                                             
end

for i=((9*T/10)+1):T                        %Exploitation phase
      for p=1 : pop                     
          if (fobj(x(p,:)) <fbest)          %Update the optimal value and solution for the entire population
          sbest=x(p,:);
          fbest=fobj(x(p,:));
          end                                                                                             
      end                               
    for j=1:pop
        fitness(j,:)=fobj(x(j,:));
        km=max(2,ceil(D/3));
        k=randi([2,km]);
        x(j,:)=sbest;
        in=randperm(D,k); 
        for h=1:k
            x(j,in(h))=x(j,in(h))+(rand*(ub(in(h))-lb(in(h)))+lb(in(h)))*(cos((i)*pi/T)+1)/2;     %Forgetting and supplementation strategy              
            if (x(j,in(h))>ub(in(h))) | (x(j,in(h))<lb(in(h)))   
                if D>15                                      %The boundary handling method when the problem dimensionality>15
                select=SELECT;     
                select(j)=[];
                sel=select(randi(pop-1));                             
                x(j,in(h))=x(sel,in(h)); 
                else                                          %The boundary handling method when the problem dimensionality<=15
                   x(j,in(h))=rand*(ub(in(h))-lb(in(h)))+lb(in(h));                
                end  
            end
        end
      end
fbest_history(i)=fbest;
% disp(['DOA Iteration ', num2str(i), ' Best fitness: ', num2str(fbest)]);                                                                 
end          
disp(['DOA: The best fitness is: ', num2str(fbest)]);
end

% This function initialize the first population of search agents
function Positions=initialization(SearchAgents_no,dim,ub,lb)

    Boundary_no= length(ub); % numnber of boundaries
    
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