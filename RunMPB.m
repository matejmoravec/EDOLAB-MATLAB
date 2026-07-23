clear; clc;

% Add the full path of EDOLAB folder and its subfolders into MATLAB's work space
nowPath = mfilename('fullpath');
projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
allPaths = genpath(projectPath);
pathsToAdd = regexprep(allPaths, '[^;]*OctaveVersion[^;]*;?', '');
addpath(pathsToAdd);

BenchmarkName = 'MPB';
ConfigurableProParameters = getProConfigurableParameters(BenchmarkName);

ConfigurableProParameters.Dimension.value         = 5;
ConfigurableProParameters.PeakNumber.value        = 10;
ConfigurableProParameters.ChangeFrequency.value   = 5000;
ConfigurableProParameters.ShiftSeverity.value     = 1.0;
ConfigurableProParameters.EnvironmentNumber.value = 20;
ConfigurableProParameters.HeightSeverity.value    = 7.0;
ConfigurableProParameters.WidthSeverity.value     = 1.0;

% Generator already uses CsvRandom('numbers.csv') internally (your modified code)
Problem = BenchmarkGenerator_MPB(BenchmarkName, ConfigurableProParameters);

Problem.MinCoordinate = -50;
Problem.MaxCoordinate = 50;
Problem.MinHeight     = 30;
Problem.MaxHeight     = 70;
Problem.MinWidth      = 1;
Problem.MaxWidth      = 12;

fprintf('MPB initialized\n');
fprintf('Max evals: %d\n', Problem.MaxEvals);
fprintf('Initial environment: %d\n', Problem.Environmentcounter);
fprintf('Initial optimum value: %.12f\n', Problem.OptimumValue(1));
%fprintf('Initial optimum peak id: %d\n', Problem.OptimumID(1));
fprintf('Initial optimum peak id: [%.2f, %.2f]\n', Problem.PeaksPosition(Problem.OptimumID(1),1,1), Problem.PeaksPosition(Problem.OptimumID(1),2,1));

% ---- Kotlin-equivalent random-search loop ----
% Kotlin: val random = CsvRandom("numbers.csv")
randomX = CsvRandom('numbers.csv');

best = -Inf;
bestX = zeros(1, Problem.Dimension);

for k = 1:Problem.MaxEvals
    x = zeros(1, Problem.Dimension);
    for d = 1:Problem.Dimension
        x(d) = randomX.nextDouble(Problem.MinCoordinate, Problem.MaxCoordinate);
    end

    % Fitness in current environment
    y = fitness_MPB(x, Problem);

    if y > best
        best = y;
        bestX = x;
    end

    % Match Kotlin evaluate() update logic
    Problem.FE = Problem.FE + 1;
    shouldChange = mod(Problem.FE, Problem.ChangeFrequency) == 0 && ...
                   Problem.Environmentcounter < Problem.EnvironmentNumber;

    if shouldChange
        Problem.Environmentcounter = Problem.Environmentcounter + 1;
        Problem.RecentChange = 1;
    else
        Problem.RecentChange = 0;
    end

    if Problem.RecentChange == 1
        envNow = Problem.Environmentcounter;
        fprintf('Environment changed at FE=%d -> env=%d, optimumValue=%.12f, optimumID=[%.2f,%.2f]\n', ...
            Problem.FE, envNow, Problem.OptimumValue(envNow), Problem.PeaksPosition(Problem.OptimumID(envNow),1,envNow), Problem.PeaksPosition(Problem.OptimumID(envNow),2,envNow));
    end
end

fprintf('Run finished.\n');
fprintf('Best found fitness: %.12f\n', best);
fprintf('Best found x: [%s]\n', strjoin(arrayfun(@(v) sprintf('%.4f', v), bestX, 'UniformOutput', false), ', '));