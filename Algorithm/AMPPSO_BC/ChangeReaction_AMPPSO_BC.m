function [Optimizer,Problem] = ChangeReaction_AMPPSO_BC(Optimizer,Problem)
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
   % 保存历史最优位置（修改顺序，先保存再更新）
   Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).GbestPosition;
   
   % 原有代码
   [Optimizer.pop(jj).FitnessValue,Problem] = fitness(Optimizer.pop(jj).X , Problem);
    Optimizer.pop(jj).PbestValue = Optimizer.pop(jj).FitnessValue;
    Optimizer.pop(jj).PbestPosition = Optimizer.pop(jj).X;
    [Optimizer.pop(jj).GbestValue,Optimizer.pop(jj).GbestID] = max(Optimizer.pop(jj).PbestValue);
    Optimizer.pop(jj).GbestPosition = Optimizer.pop(jj).PbestPosition(Optimizer.pop(jj).GbestID,:);
    Optimizer.pop(jj).Velocity = -1 + (2) *rand(size(Optimizer.pop(jj).X,1),Optimizer.Dimension);
end
  % 修改：使用自适应速度初始化
   velocity_range = max(0.5, min(2.0, Problem.Environmentcounter / 10));
   Optimizer.pop(jj).Velocity = -velocity_range + (2*velocity_range) * rand(size(Optimizer.pop(jj).X,1), Optimizer.Dimension);
end

