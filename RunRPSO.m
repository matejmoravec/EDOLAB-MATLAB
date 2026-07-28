function [Problem, Results, CurrentError, Iteration] = RunRPSO()
% Minimal runner: RPSO on MPB in EDOLAB
    %% --- Basic setup ---
    % Add the full path of EDOLAB folder and its subfolders into MATLAB's work space
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

    if isfield(ConfigurableProParameters, 'Dimension'),         ConfigurableProParameters.Dimension.value = 50; end
    if isfield(ConfigurableProParameters, 'PeakNumber'),        ConfigurableProParameters.PeakNumber.value = 99; end
    if isfield(ConfigurableProParameters, 'ChangeFrequency'),   ConfigurableProParameters.ChangeFrequency.value = 5000; end
    if isfield(ConfigurableProParameters, 'ShiftSeverity'),     ConfigurableProParameters.ShiftSeverity.value = 1.0; end
    if isfield(ConfigurableProParameters, 'EnvironmentNumber'), ConfigurableProParameters.EnvironmentNumber.value = 50; end
    if isfield(ConfigurableProParameters, 'HeightSeverity'),    ConfigurableProParameters.HeightSeverity.value = 7.0; end
    if isfield(ConfigurableProParameters, 'WidthSeverity'),     ConfigurableProParameters.WidthSeverity.value = 1.0; end


    %% --- RPSO configurable parameters ---
    ConfigurableAlgParameters = getAlgConfigurableParameters_RPSO();

    ConfigurableAlgParameters.PopulationSize.value = 5;
    ConfigurableAlgParameters.x.value = 0.729843788;
    ConfigurableAlgParameters.c1.value = 2.05;
    ConfigurableAlgParameters.c2.value = 2.05;
    ConfigurableAlgParameters.RandomizingPercentage.value = 0.5;

    %% --- Run ---
    progressInfo = struct();  % no parallel progress reporting
    progressInfo.IsParallel = false;

    [Problem, Results, CurrentError, ~, Iteration] = main_RPSO( ...
        VisualizationOverOptimization, ...
        RunNumber, ...
        BenchmarkName, ...
        ConfigurableProParameters, ...
        ConfigurableAlgParameters, ...
        progressInfo);

    %% --- Minimal console output ---
    fprintf('RPSO on MPB finished.\n');
    fprintf('Iterations: %d\n', Iteration);
    fprintf('FE: %d / %d\n', Problem.FE, Problem.MaxEvals);
    fprintf('Final Environment: %d / %d\n', Problem.Environmentcounter, Problem.EnvironmentNumber);
end