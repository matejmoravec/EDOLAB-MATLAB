function [Problem, Results, CurrentError, BestFoundValue, Iteration] = RunAMPPSO()
% Minimal runner: AMPPSO on MPB in EDOLAB
    %% --- Basic setup ---
    % Add the full path of EDOLAB folder and its subfolders into MATLAB's workspace
    nowPath = mfilename('fullpath');
    projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
    allPaths = genpath(projectPath);
    pathsToAdd = regexprep(allPaths, '[^;]*OctaveVersion[^;]*;?', '');
    addpath(pathsToAdd);

    RunNumber = 1;
    VisualizationOverOptimization = 0;   % no visualization
    BenchmarkName = 'MPB';

    %% --- Problem configurable parameters ---
    ConfigurableProParameters = getProConfigurableParameters_MPB();

    if isfield(ConfigurableProParameters, 'Dimension'),         ConfigurableProParameters.Dimension.value = 5; end
    if isfield(ConfigurableProParameters, 'PeakNumber'),        ConfigurableProParameters.PeakNumber.value = 10; end
    if isfield(ConfigurableProParameters, 'ChangeFrequency'),   ConfigurableProParameters.ChangeFrequency.value = 5000; end
    if isfield(ConfigurableProParameters, 'ShiftSeverity'),     ConfigurableProParameters.ShiftSeverity.value = 1.0; end
    if isfield(ConfigurableProParameters, 'EnvironmentNumber'), ConfigurableProParameters.EnvironmentNumber.value = 10; end
    if isfield(ConfigurableProParameters, 'HeightSeverity'),    ConfigurableProParameters.HeightSeverity.value = 7.0; end
    if isfield(ConfigurableProParameters, 'WidthSeverity'),     ConfigurableProParameters.WidthSeverity.value = 1.0; end

    %% --- AMPPSO configurable parameters ---
    ConfigurableAlgParameters = getAlgConfigurableParameters_AMPPSO();

    ConfigurableAlgParameters.initPopulationSize.value = 100;
    ConfigurableAlgParameters.w.value                  = 0.7298;
    ConfigurableAlgParameters.c1.value                 = 1.496;
    ConfigurableAlgParameters.c2.value                 = 1.496;
    ConfigurableAlgParameters.ConvergenceLimit.value   = 0.00001;
    ConfigurableAlgParameters.diversityFactor.value    = 0.005;
    ConfigurableAlgParameters.StepIndivs.value         = 10;

    %% --- Run ---
    progressInfo = struct();  % no parallel progress reporting
    progressInfo.IsParallel = false;

    [Problem, Results, CurrentError, ~, Iteration] = main_AMPPSO( ...
        VisualizationOverOptimization, ...
        RunNumber, ...
        BenchmarkName, ...
        ConfigurableProParameters, ...
        ConfigurableAlgParameters, ...
        progressInfo);

    %% --- Best found solution (algorithm output) ---
    % In EDOLAB dynamic benchmarks, CurrentError = (true optimum value - best found value) per FE.
    finalError = Problem.CurrentError(end);
    BestFoundValue = Problem.OptimumValue(Problem.Environmentcounter) - finalError;

    %% --- Minimal console output ---
    fprintf('AMPPSO on MPB finished.\n');
    fprintf('Iterations: %d\n', Iteration);
    fprintf('FE: %d / %d\n', Problem.FE, Problem.MaxEvals);
    fprintf('Final Environment: %d / %d\n', Problem.Environmentcounter, Problem.EnvironmentNumber);
    fprintf('Best Found Value: %.16g\n', BestFoundValue);
    fprintf('Optimum Value: %.16g\n', Problem.OptimumValue(Problem.Environmentcounter));
end
