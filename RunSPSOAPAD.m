function [Problem, Results, CurrentError, BestFoundValue, Iteration] = RunSPSOAPAD()
% Minimal runner: SPSO_AP_AD on MPB in EDOLAB
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

    if isfield(ConfigurableProParameters, 'Dimension'),         ConfigurableProParameters.Dimension.value = 20; end
    if isfield(ConfigurableProParameters, 'PeakNumber'),        ConfigurableProParameters.PeakNumber.value = 10; end
    if isfield(ConfigurableProParameters, 'ChangeFrequency'),   ConfigurableProParameters.ChangeFrequency.value = 5000; end
    if isfield(ConfigurableProParameters, 'ShiftSeverity'),     ConfigurableProParameters.ShiftSeverity.value = 1.0; end
    if isfield(ConfigurableProParameters, 'EnvironmentNumber'), ConfigurableProParameters.EnvironmentNumber.value = 1; end
    if isfield(ConfigurableProParameters, 'HeightSeverity'),    ConfigurableProParameters.HeightSeverity.value = 7.0; end
    if isfield(ConfigurableProParameters, 'WidthSeverity'),     ConfigurableProParameters.WidthSeverity.value = 1.0; end

    %% --- SPSO_AP_AD configurable parameters ---
    ConfigurableAlgParameters = getAlgConfigurableParameters_SPSO_AP_AD();

    % Keep defaults from getAlgConfigurableParameters_SPSO_AP_AD.m,
    % but set explicitly for clarity and reproducibility.
    ConfigurableAlgParameters.InitialPopulationSize.value   = 5;
    ConfigurableAlgParameters.SwarmMember.value             = 5;
    ConfigurableAlgParameters.NewlyAddedPopulationSize.value= 5;
    ConfigurableAlgParameters.x.value                       = 0.729843788;
    ConfigurableAlgParameters.c1.value                      = 2.05;
    ConfigurableAlgParameters.c2.value                      = 2.05;
    ConfigurableAlgParameters.rho.value                     = 0.7;
    ConfigurableAlgParameters.mu.value                      = 0.2;
    ConfigurableAlgParameters.beta.value                    = 1.0;
    ConfigurableAlgParameters.gama.value                    = 0.1;
    ConfigurableAlgParameters.Nmax.value                    = 30;

    %% --- Run ---
    progressInfo = struct();  % no parallel progress reporting
    progressInfo.IsParallel = false;

    [Problem, Results, CurrentError, ~, Iteration] = main_SPSO_AP_AD( ...
        VisualizationOverOptimization, ...
        RunNumber, ...
        BenchmarkName, ...
        ConfigurableProParameters, ...
        ConfigurableAlgParameters, ...
        progressInfo);

    %% --- Best found solution (algorithm output) ---
    % In EDOLAB dynamic benchmarks, CurrentError = (true optimum value - best found value) per FE.
    finalError = Problem.CurrentError(end);
    BestFoundValue = Problem.OptimumValue - finalError;

    %% --- Minimal console output ---
    fprintf('SPSO_AP_AD on MPB finished.\n');
    fprintf('Iterations: %d\n', Iteration);
    fprintf('FE: %d / %d\n', Problem.FE, Problem.MaxEvals);
    fprintf('Final Environment: %d / %d\n', Problem.Environmentcounter, Problem.EnvironmentNumber);
    fprintf('Best Found Value: %.16g\n', BestFoundValue);
end