%********************************SPSO_AP_AD*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 12, 2023
%
% ------------
% Reference:
% ------------
%
%  Delaram Yazdani et al.,
%            "A Species-based Particle Swarm Optimization with Adaptive Population Size and Deactivation of Species for Dynamic Optimization Problems"
%            ACM Transactions on Evolutionary Learning and Optimization, 2023.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem]= SubPopulationGenerator_SPSO_AP_AD(LB,UB,npop,dimension,Problem)
%Optimizer.X = LB + (UB-LB).*rand(npop,dimension);
U = zeros(npop,dimension);
for rr = 1:npop
    for cc = 1:dimension
        U(rr,cc) = Problem.FakeRng.nextDouble(0,1);
    end
end
Optimizer.X = LB + (UB-LB).*U;

Optimizer.PbestPosition = Optimizer.X;
Optimizer.Velocity = zeros(npop,dimension);
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X,Problem);
writeTraceLine_SPSO_AP_AD(Problem.FE, 'init', Optimizer.X(1,:), Optimizer.FitnessValue(1));
if Problem.RecentChange == 0
    Optimizer.PbestFitness = Optimizer.FitnessValue;
else
    Optimizer.FitnessValue = -inf(npop,1);
    Optimizer.PbestFitness = Optimizer.FitnessValue;
end
Optimizer.Processed = 0;
Optimizer.Shifts = [];
Optimizer.Pbest_past_environment=[];