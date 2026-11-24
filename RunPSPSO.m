function [Problem, Results, CurrentError, BestFoundValue, Iteration] = RunPSPSO()
% Minimal runner: PSPSO on MPB in EDOLAB
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

    %% --- PSPSO configurable parameters ---
    ConfigurableAlgParameters = getAlgConfigurableParameters_PSPSO();

    ConfigurableAlgParameters.w.value                  = 0.6;
    ConfigurableAlgParameters.c1.value                 = 2.83;
    ConfigurableAlgParameters.c2.value                 = 2.83;
    ConfigurableAlgParameters.SwarmNumber.value        = 10;
    ConfigurableAlgParameters.SwarmSize.value          = 7;
    ConfigurableAlgParameters.ConvergenceLimit.value   = 0.01;
    ConfigurableAlgParameters.DiversityDegree.value    = 0.7;
    ConfigurableAlgParameters.PerturbationFactor.value = 0.025;

    %% --- Run ---
    progressInfo = struct();  % no parallel progress reporting
    progressInfo.IsParallel = false;

    [Problem, Results, CurrentError, ~, Iteration] = main_PSPSO( ...
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
    fprintf('PSPSO on MPB finished.\n');
    fprintf('Iterations: %d\n', Iteration);
    fprintf('FE: %d / %d\n', Problem.FE, Problem.MaxEvals);
    fprintf('Final Environment: %d / %d\n', Problem.Environmentcounter, Problem.EnvironmentNumber);
    fprintf('Best Found Value: %.16g\n', BestFoundValue);
    fprintf('Optimum Value: %.16g\n', Problem.OptimumValue(Problem.Environmentcounter));
end
