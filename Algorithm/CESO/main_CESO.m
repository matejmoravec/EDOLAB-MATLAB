%********************************CESO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: November 4, 2022
%
% ------------
% Reference:
% ------------
%
%  Rodica Ioana Lung and Dumitru Dumitrescu,
%            "A collaborative model for tracking optima in dynamic environments"
%            IEEE Congress on Evolutionary Computation, pp. 564-567, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Problem,E_bbc,E_o,CurrentError,VisualizationInfo,Iteration] = main_CESO(VisualizationOverOptimization,PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName)
BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ChangeFrequency*EnvironmentNumber);
for RunCounter=1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter);%This random seed setting is used to initialize the Problem
    end
    Problem = BenchmarkGenerator(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName);
    rng('shuffle');%Set a random seed for the optimizer
    %% Initialiing Optimizer
    clear Optimizer;
    Optimizer.Dimension = Problem.Dimension;
    Optimizer.PopulationSizeSwarm = 10; %The swarm size must be equal or smaller than the CRDE size.
    Optimizer.PopulationSizeCRDE = 10;
    Optimizer.MaxCoordinate   = Problem.MaxCoordinate;
    Optimizer.MinCoordinate = Problem.MinCoordinate;
    Optimizer.DiversityPlus = 1;
    Optimizer.x = 0.729843788;
    Optimizer.c1 = 2.05;
    Optimizer.c2 = 2.05;
    Optimizer.ShiftSeverity = 1;%initial shift severity
    Optimizer.theta = 1;
    Optimizer.CR = 0.9;
    Optimizer.F = 0.5;  
    Optimizer.Vmax = 0.1; %Velocity boundary. Default value for upper and lower bound is (-0.1,0.1)
    Optimizer.Vmin = -0.1;
    [Optimizer,Problem] = SubPopulationGenerator_CESO(Optimizer,Problem);
    VisualizationFlag=0;
    Iteration=0;
    if VisualizationOverOptimization==1
        VisualizationInfo = cell(1,Problem.MaxEvals);
    else
        VisualizationInfo = [];
    end
    %% main loop
    while 1
        Iteration = Iteration + 1;
        %% Visualization for education module
        if (VisualizationOverOptimization==1 && Dimension == 2)
            if VisualizationFlag==0
                VisualizationFlag=1;
                T = Problem.MinCoordinate : ( Problem.MaxCoordinate-Problem.MinCoordinate)/100 :  Problem.MaxCoordinate;
                L=length(T);
                F=zeros(L);
                for i=1:L
                    for j=1:L
                        F(i,j) = EnvironmentVisualization([T(i), T(j)],Problem);
                    end
                end
            end
            VisualizationInfo{Iteration}.T=T;
            VisualizationInfo{Iteration}.F=F;
            VisualizationInfo{Iteration}.Problem.PeakVisibility = Problem.PeakVisibility(Problem.Environmentcounter,:);
            VisualizationInfo{Iteration}.Problem.OptimumID = Problem.OptimumID(Problem.Environmentcounter);
            VisualizationInfo{Iteration}.Problem.PeaksPosition = Problem.PeaksPosition(:,:,Problem.Environmentcounter);
            VisualizationInfo{Iteration}.CurrentEnvironment = Problem.Environmentcounter;
            counter = 0;
            for jj=1 :size(Optimizer.pop.X,1)
                counter = counter + 1;
                VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.pop.X(jj,:);
            end
            for jj=1 :size(Optimizer.CRDE.X,1)
                counter = counter + 1;
                VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.CRDE.X(jj,:);
            end            
            VisualizationInfo{Iteration}.IndividualNumber = counter;
            VisualizationInfo{Iteration}.FE = Problem.FE;
        end
        %% Optimization
        [Optimizer,Problem] = IterativeComponents_CESO(Optimizer,Problem);
        if Problem.RecentChange == 1%When an environmental change has happened
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_CESO(Optimizer,Problem);            
            VisualizationFlag = 0;
            clc; disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
        end
        if  Problem.FE >= Problem.MaxEvals%When termination criteria has been met
            break;
        end
    end
    %% Performance indicator calculation
    BestErrorBeforeChange(1,RunCounter) = mean(Problem.Ebbc);
    OfflineError(1,RunCounter) = mean(Problem.CurrentError);
    CurrentError(RunCounter,:) = Problem.CurrentError;
end
%% Output preparation
E_bbc.mean = mean(BestErrorBeforeChange);
E_bbc.median = median(BestErrorBeforeChange);
E_bbc.StdErr = std(BestErrorBeforeChange)/sqrt(RunNumber);
E_bbc.AllResults = BestErrorBeforeChange;
E_o.mean = mean(OfflineError);
E_o.median = median(OfflineError);
E_o.StdErr = std(OfflineError)/sqrt(RunNumber);
E_o.AllResults =OfflineError;
if VisualizationOverOptimization==1
    tmp = cell(1, Iteration);
    for ii=1 : Iteration
        tmp{ii} = VisualizationInfo{ii};
    end
    VisualizationInfo = tmp;
end    