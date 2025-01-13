clear all;close all;clc;
%% Add the full path of EDOLAB folder and its subfolders into MATLAB's work space
nowPath = mfilename('fullpath');
projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
addpath(genpath(projectPath));
%% ********Selecting Benchmark********
BenchmarkName = 'GMPB';
%% Get the algorithm and benchmark lists
AlgorithmsFolder = dir([projectPath,'\Algorithm']);
AlgorithmsList = repmat("",length(AlgorithmsFolder)-2,1);
for i = 3:length(AlgorithmsFolder)
    AlgorithmsList(i-2,1) = AlgorithmsFolder(i).name;
end
BenchmarksFolder = dir([projectPath,'\Benchmark']);
BenchmarksList = repmat("",length(BenchmarksFolder)-5,1);
BenchmarksCount = 0;
for i = 3:length(BenchmarksFolder)
    if(isempty(strfind(BenchmarksFolder(i).name,'.m')))
        BenchmarksCount = BenchmarksCount + 1;
        BenchmarksList(BenchmarksCount,1) = BenchmarksFolder(i).name;
    end
end
if(~ismember(BenchmarkName,BenchmarksList))
    error("No Such Benchmark in EDOLAB");
end
%% ********Benchmark parameters and Run number********
PeakNumber                     = 10;    % The default value is 10
ChangeFrequency                = 2500;  % The default value is 5000
Dimension                      = 5;     % The default value is 5. It must be set to 2 for using Education module
ShiftSeverity                  = 1;     % The default value is 1
EnvironmentNumber              = 100;   % The default value is 100
RunNumber                      = 31;    % It should be set to 31.
SampleInterval                 = 100;   % Comparison parameter
%% ********Figures and Outputs********
VisualizationOverOptimization  = 0; % This must be set to 0 if the user intends to use the Experimentation module.
%% Run all algorithms on the chosen benchmark
for i = 1:size(AlgorithmsList,1)
    %% Running the chosen algorithm on the chosen benchmark
    AlgorithmName = AlgorithmsList(i);
    main_EDO = str2func(['main_',char(AlgorithmName)]);
    [fitnesses,~,E_bbc,E_o,T_r,~,~,~] = main_EDO(VisualizationOverOptimization,PeakNumber,ChangeFrequency,SampleInterval,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName);
    %% Output
    disp(['Offline error ==> ', ' Mean = ', num2str(E_o.mean), ', Median = ', num2str(E_o.median), ', Standard Error = ', num2str(E_o.StdErr)]);
    disp(['Average error before change ==> ', ' Mean = ', num2str(E_bbc.mean), ', Median = ', num2str(E_bbc.median), ', Standard Error = ', num2str(E_bbc.StdErr)]);
    disp(['Runtime ==> ', ' Mean = ', num2str(T_r.mean), 's, Median = ', num2str(T_r.median), 's, Standard Error = ', num2str(T_r.StdErr), 's']);
    %% Generating text files containing fitness values for all runs by selected evaluation for comparison
    folderPath = fullfile(projectPath, "Results", "Comparison", "CEC2024");
    folderName = [BenchmarkName, '_Peaks', num2str(PeakNumber), '_ChangeFrequency', num2str(ChangeFrequency), '_D', num2str(Dimension), '_ShiftSeverity', num2str(ShiftSeverity), '_Environments', num2str(EnvironmentNumber)];
    fullFolderPath = fullfile(folderPath, folderName);
    if ~exist(fullFolderPath, 'dir')
        mkdir(fullFolderPath);
    end
    numCols = size(fitnesses, 2);
    evaluationNumber = SampleInterval;
    col = 1;
    while col <= numCols
        filename = [char(AlgorithmName), '_', BenchmarkName, 'Eval', num2str(evaluationNumber), '.txt'];
        fullFilePath = fullfile(fullFolderPath, filename);
        SaveAlgorithmResults(fullFilePath, fitnesses(:, col));
        col = col + 1;
        % Check if an additional save is needed (after environment change)
        if mod(evaluationNumber, ChangeFrequency) == 0 && evaluationNumber ~= ChangeFrequency * EnvironmentNumber
            filename = [char(AlgorithmName), '_', BenchmarkName, 'Eval', num2str(evaluationNumber+1), '.txt'];
            fullFilePath = fullfile(fullFolderPath, filename);
            SaveAlgorithmResults(fullFilePath, fitnesses(:, col));
            col = col + 1;
        end
        evaluationNumber = evaluationNumber + SampleInterval;
    end
end