clear all;close all;clc;
%% Add the full path of EDOLAB folder and its subfolders into MATLAB's work space
nowPath = mfilename('fullpath');
projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
addpath(genpath(projectPath));
%% ********Selecting Algorithm & Benchmark********
%AlgorithmName = 'AMPDE';
BenchmarkName = 'MPB';
%% Get the algorithm and benchmark lists
AlgorithmsFloder = dir([projectPath,'\Algorithm']);
AlgorithmsList = repmat("",length(AlgorithmsFloder)-2,1);
for i = 3:length(AlgorithmsFloder)
    AlgorithmsList(i-2,1) = AlgorithmsFloder(i).name;
end
BenchmarksFloder = dir([projectPath,'\Benchmark']);
BenchmarksList = repmat("",length(BenchmarksFloder)-5,1);
BenchmarksCount = 0;
for i = 3:length(BenchmarksFloder)
    if(isempty(strfind(BenchmarksFloder(i).name,'.m')))
        BenchmarksCount = BenchmarksCount + 1;
        BenchmarksList(BenchmarksCount,1) = BenchmarksFloder(i).name;
    end
end
%if(~ismember(AlgorithmName,AlgorithmsList))
%    error("No Such Algorithm in EDOLAB");
if(~ismember(BenchmarkName,BenchmarksList))
    error("No Such Benchmark in EDOLAB");
end
%% ********Benchmark parameters and Run number********
PeakNumber                     = 10;    % The default value is 10
ChangeFrequency                = 5000;  % The default value is 5000
Dimension                      = 5;     % The default value is 5. It must be set to 2 for using Education module
ShiftSeverity                  = 1;     % The default value is 1
EnvironmentNumber              = 3;     % The default value is 100
RunNumber                      = 31;    % It should be set to 31.
SampleInterval                 = 1000;  % Comparison parameter
%% ********Figures and Outputs********
GeneratingExcelFile            = 1; % Set to 1 to save the output statistics in an Excel file (in the Results folder), 0 otherwise. 
OutputFig                      = 1; % Set to 1 to draw offline error over time and current error plot, 0 otherwise.
VisualizationOverOptimization  = 0; % This must be set to 0 if the user intends to use the Experimentation module.
%% Running the chosen algorithm on the chosen benchmark
for i = 1:size(AlgorithmsList)
    main_EDO = str2func(['main_',char(AlgorithmsList(i))]);
    [fitnesses,Problem,E_bbc,E_o,CurrentError,VisualizationInfo,Iteration] = main_EDO(VisualizationOverOptimization,PeakNumber,ChangeFrequency,SampleInterval,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName);
    %% Output
    close;clc;
    disp(['Offline error ==> ', ' Mean = ', num2str(E_o.mean), ', Median = ', num2str(E_o.median), ', Standard Error = ', num2str(E_o.StdErr)]);
                            (['Average error before change ==> ', ' Mean = ', num2str(E_bbc.mean), ', Median = ', num2str(E_bbc.median), ', Standard Error = ', num2str(E_bbc.StdErr)]);
    
    %% Generating text files containing fitness values for all runs by selected evaluation for EDOAs comparison.
    folderPath = ['D:\EDOLAB-MATLAB', '\Results\Comparison\DeleteAfterTest'];
    cd(folderPath);
    folderName = [BenchmarkName, '_Peaks', num2str(PeakNumber), '_ChangeFrequency', num2str(ChangeFrequency), '_D', num2str(Dimension), '_ShiftSeverity', num2str(ShiftSeverity), '_Environments', num2str(EnvironmentNumber)];
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end
    cd(folderName);
    numCols = size(fitnesses, 2);
    evaluationNumber = SampleInterval;
    col = 1;
    while col <= numCols
        if mod(evaluationNumber, ChangeFrequency) == 0 && evaluationNumber ~= ChangeFrequency * EnvironmentNumber
            filename = [char(AlgorithmsList(i)), '_', BenchmarkName, 'Eval', num2str(evaluationNumber), '.txt'];
            SaveAlgorithmResults(filename, fitnesses(:, col));
            col = col + 1;
            filename = [char(AlgorithmsList(i)), '_', BenchmarkName, 'Eval', num2str(evaluationNumber+1), '.txt'];
            SaveAlgorithmResults(filename, fitnesses(:, col));
            col = col + 1;
        else
            filename = [char(AlgorithmsList(i)), '_', BenchmarkName, 'Eval', num2str(evaluationNumber), '.txt'];
            SaveAlgorithmResults(filename, fitnesses(:, col));
            col = col + 1;
        end
        evaluationNumber = evaluationNumber + SampleInterval;
    end
end