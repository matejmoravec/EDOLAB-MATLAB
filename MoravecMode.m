clear all;close all;clc;
%% Add the full path of EDOLAB folder and its subfolders into MATLAB's work space
nowPath = mfilename('fullpath');
projectPath = nowPath(1:max(strfind(nowPath, '\')) - 1);
allPaths = genpath(projectPath);
pathsToAdd = regexprep(allPaths, '[^;]*OctaveVersion[^;]*;?', '');
addpath(pathsToAdd);
%% ********Selecting Algorithm(s) & Benchmark********
AlgorithmNames = {'ACFPSO', 'AMPDE', 'AMPPSO', 'AmQSO', 'AMSO', 'APCPSO', 'CDE', 'CESO', 'CPSO', 'CPSOR', 'DPCPSO', 'DSPSO', 'DynDE', 'DynPopDE', 'FTMPSO', 'HmSO', 'IDSPSO', 'ImQSO', 'mCMAES', 'mDE', 'mjDE', 'mPSO', 'mQSO', 'psfNBC', 'RPSO', 'SPSO_AP_AD', 'TMIPSO'};   % Please input the name of algorithm(s) (EDOA(s)) you want to run here (names are case sensitive).
BenchmarkName = 'GMPB';                  % Please input the name of benchmark you want to use here (names are case sensitive).
%% Get the algorithm and benchmark lists
AlgorithmsFolder = dir([projectPath, '\Algorithm']);
AlgorithmsList = repmat("", length(AlgorithmsFolder) - 2, 1);
for i = 3:length(AlgorithmsFolder)
    AlgorithmsList(i - 2,1) = AlgorithmsFolder(i).name;
end
BenchmarksFolder = dir([projectPath, '\Benchmark']);
BenchmarksList = repmat("", length(BenchmarksFolder) - 5, 1);
BenchmarksCount = 0;
for i = 3:length(BenchmarksFolder)
    if(isempty(strfind(BenchmarksFolder(i).name, '.m')))
        BenchmarksCount = BenchmarksCount + 1;
        BenchmarksList(BenchmarksCount, 1) = BenchmarksFolder(i).name;
    end
end
for i = 1:length(AlgorithmNames)
    if(~ismember(AlgorithmNames{i}, AlgorithmsList))
        error("No Such Algorithm in EDOLAB");
    end
end
if(~ismember(BenchmarkName,BenchmarksList))
    error("No Such Benchmark in EDOLAB");
end
%% Loop through all algorithms (EDOAs)
for i = 1:length(AlgorithmNames)
    %% ********Algorithm parameters, Benchmark parameters and Run number********
    % To modify configuration parameters, please edit:
    % - Algorithm settings: getAlgConfigurableParameters_[EDO].m in the selected algorithm folder
    % - Problem settings: getProConfigurableParameters_[Benchmark].m in the selected problem folder
    ConfigurableAlgParameters = getAlgConfigurableParameters(AlgorithmNames{i});
    ConfigurableProParameters = getProConfigurableParameters(BenchmarkName);
    Dimension                      = ConfigurableProParameters.Dimension.value;
    RunNumber                      = 31;   %It should be set to 31 in Experimentation module, and must be set to 2 for using Education module.
    %% ********Figures and Outputs********
    GeneratingExcelFile            = 1;   % Set to 1 (only for using the Experimentation module) to save the output statistics in an Excel file (in the Results folder), 0 otherwise. 
    OutputFig                      = 1;   % Set to 1 (only for using the Experimentation module) to draw offline error over time and current error plot, 0 otherwise.
    VisualizationOverOptimization  = 0;   % Set to 1 for using the Education module, 0 otherwise. This must be set to 0 if the user intends to use the Experimentation module.
    % If VisualizationOverOptimization is set to 1, it means that EDOLAB enters its Education module. 
    % To enter the Education module, RunNumber must be set to 1, Dimension must be set to 2, and no excel file or output figure is generated. 
    % If the user does not intend to use the Education module, she or he must set VisualizationOverOptimization to 0. 
    % EDOLAB changes the aforementioned parameters based on the requirements of the Education module if VisualizationOverOptimization is set to 1.
    if VisualizationOverOptimization == 1 % Forcing the right values for the following parameters when using the Education module.  
        if Dimension ~= 2 || RunNumber ~= 1 || GeneratingExcelFile ~= 0 || OutputFig ~= 0
           warning('By setting VisualizationOverOptimization to 1, you have chosen to use the Education module of EDOLAB; therefore, run number and dimension are set to 1 and 2, respectively. The output figure and Excel file are disabled.');      
        end
        ConfigurableProParameters.Dimension.value                  = 2;   
        RunNumber                                                  = 1;
        GeneratingExcelFile                                        = 1;   
        OutputFig                                                  = 0;
    end
    %% EARS
    MaxFEs = ConfigurableProParameters.EnvironmentNumber.value * ConfigurableProParameters.ChangeFrequency.value;
    ChangeFrequency = ConfigurableProParameters.ChangeFrequency.value;
    Moravec.SampleInterval  = 100;
    Moravec.NumSamples = MaxFEs / Moravec.SampleInterval + ConfigurableProParameters.EnvironmentNumber.value;
    Moravec.NumRuns = RunNumber;
    Moravec.FEs = sort([1, Moravec.SampleInterval:Moravec.SampleInterval:MaxFEs, (ChangeFrequency + 1):ChangeFrequency:MaxFEs]);
    Moravec.FitnessValues = NaN(Moravec.NumSamples, Moravec.NumRuns);
    %% Running the chosen algorithm (EDOA) on the chosen benchmark and save results in TXT file
    main_EDO = str2func(['main_', AlgorithmNames{i}]);
    ProgressInfo = struct('IsParallel', false);
    [Problem, Results, CurrentError, VisualizationInfo, Iteration, Moravec] = ...
        main_EDO(VisualizationOverOptimization, RunNumber, BenchmarkName, ConfigurableProParameters, ConfigurableAlgParameters, ProgressInfo, Moravec);
    folderPath = fullfile(projectPath, "Results", "Moravec", "CEC2025");
    folderName = [BenchmarkName, '_Peaks', num2str(ConfigurableProParameters.PeakNumber.value), '_ChangeFrequency', num2str(ChangeFrequency), '_ShiftSeverity', num2str(ConfigurableProParameters.ShiftSeverity.value), '_Environments', num2str(ConfigurableProParameters.EnvironmentNumber.value), '_Dim', num2str(ConfigurableProParameters.Dimension.value)];
    fullFolderPath = fullfile(folderPath, folderName);
    if ~exist(fullFolderPath, 'dir')
        mkdir(fullFolderPath);
    end
    filename = [AlgorithmNames{i}, '_', BenchmarkName, '.txt'];
    fullFilePath = fullfile(fullFolderPath, filename);
    writematrix(Moravec.FitnessValues, fullFilePath, 'Delimiter', ',');

    % Generating an Excel file containing output statistics (only for the Experimentation module)
    if GeneratingExcelFile==1
        OutputDetailResultsToExcel(AlgorithmNames{i}, ConfigurableAlgParameters, BenchmarkName, ConfigurableProParameters, Results, [projectPath,'\Results\Moravec\CEC2025\Indicators']);
    end
end